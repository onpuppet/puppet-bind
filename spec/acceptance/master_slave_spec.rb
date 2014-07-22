require 'spec_helper_acceptance'

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
          listen_on_addr    => [ 'any' ],
          listen_on_v6_addr => [ 'any' ],
          allow_notify      => [ '#{slave_ipv4}', '#{slave_ipv6}' ],  
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
            listen_on_addr    => [ 'any' ],
            listen_on_v6_addr => [ 'any' ],
          }
    EOS

    # Run it twice and test for idempotency
    expect(apply_manifest_on(database, pp).exit_code).to_not(eq(1))
    expect(apply_manifest_on(database, pp).exit_code).to(eq(0))
  end

end