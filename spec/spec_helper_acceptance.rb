require 'beaker-rspec'

UNSUPPORTED_PLATFORMS = [ 'Windows', 'Solaris', 'AIX' ]

#unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'
#  if hosts.first.is_pe?
#    install_pe
#  else
#    install_puppet
#  end
#  hosts.each do |host|
#    on hosts, "mkdir -p #{host['distmoduledir']}"
#  end
#end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'bind')
    hosts.each do |host|
      # Set up static ip
      host.inspect
      
      # Required for binding tests.
      if fact('osfamily') == 'RedHat'
        version = fact("operatingsystemmajrelease")
        shell("yum localinstall -y http://yum.puppetlabs.com/puppetlabs-release-el-#{version}.noarch.rpm")
      end

      shell("/bin/touch #{default['puppetpath']}/hiera.yaml")
#      shell('puppet module install puppetlabs-stdlib --version 3.2.0', { :acceptable_exit_codes => [0,1] })
      on host, puppet('module','install','puppetlabs/concat'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
