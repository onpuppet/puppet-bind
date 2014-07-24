require 'spec_helper_acceptance'
require 'spec/dns'
require 'csv'

describe 'bind' do

  case fact('osfamily')
  when 'RedHat'
    if fact('operatingsystemmajrelease') == '7'
      package_name = 'named'
      service_name = 'named'
      service_provider = 'undef'
    else
      package_name = 'named'
      service_name = 'named'
      service_provider = 'undef'
    end
  when 'Suse'
    package_name = 'named'
    service_name = 'named'
    service_provider = 'undef'
  when 'Debian'
    case fact('operatingsystem')
    when 'Debian'
      package_name = 'bind'
      service_name = 'named'
      service_provider = 'undef'
    when 'Ubuntu'
      package_name = 'bind9'
      service_name = 'bind9'
      service_provider = 'upstart'
    end
  end

  master_ipv4 = on( master, facter('ipaddress')).stdout.strip
  slave_ipv4 = on( database, facter('ipaddress')).stdout.strip
  master_ipv6 = on( master, facter('ipaddress6')).stdout.strip
  slave_ipv6 = on( database, facter('ipaddress6')).stdout.strip

  master_ips = if master_ipv6.nil? then "'#{master_ipv4}'" else "'#{master_ipv4}', '#{master_ipv6}'" end
  slave_ips = if master_ipv6.nil? then "'#{slave_ipv4}'" else "'#{slave_ipv4}', '#{slave_ipv6}'" end
  
  # TODO parse facter('netmask') from 255.255.0.0 syntax to 172.17.0.0/16

  # Using puppet_apply as a helper
  it 'should install master with no errors' do
    pp = <<-EOS
        class { 'bind': 
          allow_notify      => [ #{slave_ips} ],
          forwarders        => [ '144.254.71.184' ] 
        }
        
        bind::zone { 'example.com':
          nameservers    => ['ns1.example.com', 'ns2.example.com'],
          allow_transfer => [ #{slave_ips} ],
        }
  
        bind::zone { '12.168.192.IN-ADDR.ARPA':
          nameservers    => ['ns1.example.com', 'ns2.example.com'],
          allow_transfer => [ #{slave_ips} ],
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
            masters => { 'masterlist' => [ #{master_ips} ] },
            forwarders        => [ '144.254.71.184' ] 
          }
    EOS

    # Run it twice and test for idempotency
    expect(apply_manifest_on(database, pp).exit_code).to_not(eq(1))
    expect(apply_manifest_on(database, pp).exit_code).to(eq(0))
  end

  describe package(package_name) do
    it { should be_installed }
  end

  describe service(service_name) do
    it { should be_running }
    it { should be_enabled }
  end

  ##### Inspired by: http://sharknet.us/2014/02/06/infrastructure-testing-with-ansible-and-serverspec-part-2/

#  describe "Record Lookup" do
#    before(:all) do
#      @domain_name = 'example.com'
#      # Cache DNS servers
#      @dns_servers ||= []
#      @dns_servers.push( DNS.new(master_ipv4, 'Master', @domain_name ))
#      @dns_servers.push( DNS.new(slave_ipv4, 'Slave', @domain_name ))
#      # You can add others here
#
#      # Load DNS records from a CSV file
#      @records = CSV.readlines('spec/acceptance/records.csv')
#    end
#
#    it "Should return the correct IP address for static hostnames (A records)" do
#      @dns_servers.each do |nameserver|
#        @records.each do |record|
#          if record[2] == 'A'
#            expect(nameserver.is_host?(record[0],record[1])).to be_true , "Server #{nameserver} did not find IP address #{record[1]} for #{record[0]}"
#          end
#        end
#      end
#    end
#
#    it "Should return the correct hostname for static IP addresses (PTR records)" do
#      @dns_servers.each do |nameserver|
#        @records.each do |record|
#          if record[2] == 'A'
#            expect(nameserver.is_pointer?(record[1],record[0])).to be_true , "Server #{nameserver} did not find host name #{record[0]} for #{record[1]}"
#          end
#        end
#      end
#    end
#
#    it "Should resolve external host names." do
#      external_hosts = [
#        "www.google.com",
#        "www.cnn.com",
#        "www.facebook.com"
#      ]
#      @dns_servers.each do |nameserver|
#        external_hosts.each do |host|
#          ip = nameserver.address( host )
#          expect(ip).to_not eql('Hostname not found'), "Server #{nameserver} could not resolve #{host}"
#        end
#      end
#    end
#
#    it "Should return the correct mail servers (MX records)" do
#      @dns_servers.each do |nameserver|
#        @records.each do |record|
#          if record[2] == 'MX'
#            exists = nameserver.is_mail_server?( @domain_name, record[0], 10 )
#            expect(exists).to be_true, "Server #{nameserver} did have an MX record for #{record[0]}"
#          end
#        end
#      end
#    end
#
#    it "Should return the correct nameservers (NS records)" do
#      @dns_servers.each do |nameserver|
#        @records.each do |record|
#          if record[2] == 'NS'
#            exists = nameserver.is_nameserver?( @domain_name, record[0] )
#            expect(exists).to be_true, "Server #{nameserver} did have an NS record for #{record[0]}"
#          end
#        end
#      end
#    end
#
#    it "Should return the correct aliases (CNAME records)" do
#      @dns_servers.each do |nameserver|
#        @records.each do |record|
#          if record[2] == 'CNAME'
#            exists = nameserver.is_alias?( record[0], record[1] )
#            expect(exists).to be_true, "Server #{nameserver} did have a CNAME record for #{record[0]} that aliased to #{record[1]}"
#          end
#        end
#      end
#    end
#
#  end

end