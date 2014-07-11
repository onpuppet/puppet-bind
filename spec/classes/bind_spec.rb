require 'spec_helper'

describe 'bind' do
  # Workaround for missing pluginsync
  let :facts do
    { :concat_basedir => '/tmp' } 
   end
  
  it 'should compile' do
    expect { should contain_class('bind') }
  end

  it { should contain_package('bind').with_ensure('installed') }
  it { should contain_service('named').with({
  	'hasstatus' => true,
  	'enable' => true,
  	'ensure' => 'running',
  	'restart' => '/sbin/service named reload'
  	})}
  it 'should create the logging directory' do
  	expect { should contain_file('/var/log/named').with({
  		'ensure' => 'directory',
  		'owner' => 'root',
  		'group' => 'named',
  		'mode' => '0770',
  		'seltype' => 'var_log_t'
  		})}
  end

  # Config params
#  let (:config_file)  { '/etc/named.conf' }
#  let (:params) { {
#    :acls => { 
#      'rfc1918' => [ '10/8', '172.16/12', '192.168/16' ] 
#    },
#    :masters => {
#      'mymasters' => ['192.0.2.1', '198.51.100.1']
#    },
#    :zones => {
#      'example.com' => [
#        'type master',
#        'file "example.com"',
#      ],
#      'example.org' => [
#        'type slave',
#        'file "slaves/example.org"',
#        'masters { mymasters; }',
#      ],
#    },
#    :includes => [
#      '/etc/myzones.conf',
#    ],
#  } }
#
#  it 'should generate the bind configuration' do
#    expect { should contain_file ('/etc/named.conf')}
#    content = catalogue.resource('file', '/etc/named.conf').send(:parameters)[:content]
#        content.should_not be_empty
#        content.should match('acl rfc1918')
#        content.should match('masters mymasters')
#        content.should match('zone "example.com"')
#        content.should match('zone "example.org"')
#        content.should match('include "/etc/myzones.conf"')
#  end
    
  
  # Config file
#  let(:title) { 'example.com' }
#  let (:params) {{
#    :source => 'puppet:///modules/bind/named.empty'
#  }}
#
#  it { should contain_file('/var/named/example.com') }
  
end