require 'spec_helper_acceptance'

describe 'bind' do
  
  master_ip = on( master, facter('ipaddress')).stdout.strip
  slave_ip = on( database, facter('ipaddress')).stdout.strip

  # TODO parse facter('netmask') from 255.255.0.0 syntax to 172.17.0.0/16
    
    # Using puppet_apply as a helper
    it 'should install master with no errors' do
      pp = <<-EOS
        class { 'bind': 
          listen_on_addr    => [ 'any' ],
          listen_on_v6_addr => [ 'any' ],
        }
      EOS
      
      # Run it twice and test for idempotency
      expect(apply_manifest_on(master, pp).exit_code).to_not(eq(1))
      expect(apply_manifest_on(master, pp).exit_code).to(eq(0))
    end

  it 'should install slave with no errors' do
        pp = <<-EOS
          class { 'bind': 
            masters => { 'masterlist' => [ '#{master_ip}' ] },
            listen_on_addr    => [ 'any' ],
            listen_on_v6_addr => [ 'any' ],
          }
        EOS
        
#        pp = "class { 'bind': masters => { 'masters' => [ '" + master_ip + "' ] } }"
        
        # Run it twice and test for idempotency
        expect(apply_manifest_on(database, pp).exit_code).to_not(eq(1))
        expect(apply_manifest_on(database, pp).exit_code).to(eq(0))
      end
    
#    describe package(package_name) do
#      it { should be_installed }
#    end
#
#    describe service(service_name) do
#      it { should be_running }
#      it { should be_enabled }
#    end
  

#  on slave do
#    logger.notify "slave has ip:" + host['ip']
#    
#  
#    # Using puppet_apply as a helper
#    it 'should work with no errors' do
#      pp = <<-EOS
#         class { 'bind': }
#      EOS
#
#      # Run it twice and test for idempotency
#      expect(apply_manifest(pp).exit_code).to_not eq(1)
#      expect(apply_manifest(pp).exit_code).to eq(0)
#    end
#
#    describe package(package_name) do
#      it { should be_installed }
#    end
#
#    describe service(service_name) do
#      it { should be_running }
#      it { should be_enabled }
#    end
#  end
  
#  let(:hosts)  { Host.new('blah', 'blah', 'not helpful') }
#
#  after do
#    on master, puppet('resource mything ensure=absent')
#    on agents, 'kill -9 allTheThings'
#  end
#
#  it 'tests stuff?' do
#    result = on( hosts.first, 'ls ~' )
#    expect( result.stdout ).to match(/my_file/)
#  end
end




