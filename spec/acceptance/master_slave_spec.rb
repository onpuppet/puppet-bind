require 'spec_helper_acceptance'
require 'dns'

describe 'bind' do

  master_ipv4 = on( master, facter('ipaddress')).stdout.strip
  slave_ipv4 = on( database, facter('ipaddress')).stdout.strip
  master_ipv6 = on( master, facter('ipaddress6')).stdout.strip
  slave_ipv6 = on( database, facter('ipaddress6')).stdout.strip

  # TODO parse facter('netmask') from 255.255.0.0 syntax to 172.17.0.0/16

  # Using puppet_apply as a helper
  it 'should install master with no errors' do
    pp = <<-EOS
        class { 'bind': 
          allow_notify      => [ '#{slave_ipv4}', '#{slave_ipv6}' ],  
        }
        
        bind::zone { 'example.com':
          nameservers    => ['ns1.example.com', 'ns2.example.com'],
          allow_transfer => [ '#{slave_ipv4}', '#{slave_ipv6}' ],
        }
  
        bind::zone { '168.192.in-addr.arpa':
          nameservers    => ['ns1.example.com', 'ns2.example.com'],
          allow_transfer => [ '#{slave_ipv4}', '#{slave_ipv6}' ],
        }
        
        bind::record::a {
          'gateway':
            zone => 'example.com',
            data => '192.168.12.1',
            ptr  => true
        }
        
        bind::record::a {
          'mail':
            zone => 'example.com',
            data => '192.168.12.3',
            ptr  => true
        }
    EOS

    # Run it twice and test for idempotency
    expect(apply_manifest_on(master, pp).exit_code).to_not(eq(1))
    expect(apply_manifest_on(master, pp).exit_code).to(eq(0))
  end

  it 'should install slave with no errors' do
    pp = <<-EOS
          class { 'bind': 
            masters => { 'masterlist' => [ '#{master_ipv4}', '#{master_ipv6}' ] },
          }
    EOS

    # Run it twice and test for idempotency
    expect(apply_manifest_on(database, pp).exit_code).to_not(eq(1))
    expect(apply_manifest_on(database, pp).exit_code).to(eq(0))
  end

  describe "DNS Server Infrastructure" do
    describe "Record Lookup" do
      before(:all) do
        # Cache DNS servers
        @dns_servers ||= []
        @dns_servers.push( DNS.new(master_ipv4, 'Master', 'example.com' ))
#        @dns_servers.push( DNS.new(master_ipv6, 'Master', 'example.com' ))
        @dns_servers.push( DNS.new(slave_ipv4, 'Slave', 'example.com' ))
#        @dns_servers.push( DNS.new(slave_ipv6, 'Slave', 'example.com' ))

        # Load DNS records from a CSV file
        @records = CSV.readlines('spec/acceptance/records.csv')
      end

      it "Should return the correct IP address for static hostnames (A records)" do
        @dns_servers.each do |nameserver|
          @records.each do |record|
            if record[2] == 'A'
              ip = nameserver.address( record[0] )
              expect(ip).to eql( record[1] ), "Server #{nameserver} returned #{ip} instead of #{record[1]} for #{record[0]}"
            end
          end
        end
      end

      it "Should return the correct hostname for static IP addresses (PTR records)" do
        @dns_servers.each do |nameserver|
          @records.each do |record|
            if record[2] == 'A'
              host = nameserver.hostname( record[1] )
              expect(host).to eql( record[0] ), "Server #{nameserver} returned #{host} instead of #{record[0]} for #{record[1]}"
            end
          end
        end
      end

      it "Should return an IP within the DHCP scope range." do
        @dns_servers.each do |nameserver|
          CSV.open('spec/acceptance/dynamic_hosts.csv', 'r') do |record|
            ip = nameserver.address( record[0] )
            expect(ip).to_not eql('Hostname not found'), "Server #{nameserver} could not resolve #{record[0]}"
            expect( nameserver.host_in_range?( ip,record[1],record[2])).to be_true, "Server #{nameserver} returned IP address #{ip} for #{record[0]} outside of range."
          end
        end
      end

      it "Should resolve external host names." do
        external_hosts = [
          "www.google.com",
          "www.cnn.com",
          "www.facebook.com"
        ]
        @dns_servers.each do |nameserver|
          external_hosts.each do |host|
            ip = nameserver.address( host )
            expect(ip).to_not eql('Hostname not found'), "Server #{nameserver} could not resolve #{host}"
          end
        end
      end

    end
  end

end