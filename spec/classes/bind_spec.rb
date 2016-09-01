require 'spec_helper'

describe 'bind' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do

        let(:title) { 'bind' }
        let(:parser) { 'future' }
        let(:node) { 'rspec.node1' }
        let(:facts) do
          facts.merge({
            :ipaddress => '10.0.0.10',
            :concat_basedir => '/tmp'
          })
        end
        let(:params) { { :config_file => '/etc/bind/named.conf', :package => 'bind', 'servicename' => 'bind' } }

        describe 'Test that catalogue compiles' do
          it { should compile.with_all_deps }
          it { should contain_class('bind') }
        end

        describe 'Test standard installation' do
          it { should contain_package('bind').with_ensure('present') }
          it { should contain_service('bind').with_ensure('running') }
          it { should contain_service('bind').with_enable(true) }
          it { should contain_service('bind').with_hasstatus(true) }

          case facts[:osfamily]
          when 'Debian'
            it { should contain_file('/etc/bind/named.conf') }
            it 'should create the logging directory' do
              expect { should contain_file('/var/log/named').with({
                  'ensure' => 'directory',
                  'owner' => 'root',
                  'group' => 'named',
                  'mode' => '0770',
                  'seltype' => 'var_log_t'
                })}
            end
          when 'RedHat'
#            it { should contain_file('/etc/named/named.conf') }
            it 'should create the logging directory' do
              expect { should contain_file('/var/log/named').with({
                  'ensure' => 'directory',
                  'owner' => 'root',
                  'group' => 'named',
                  'mode' => '0770',
                  'seltype' => 'var_log_t'
                })}
            end
          end

        end

        describe 'Test installation with custom config and zones' do
          let(:params) { {
              :config_file => '/etc/named.conf',
              :acls => {
              'rfc1918' => [ '10/8', '172.16/12', '192.168/16' ]
              },
              :masters => {
              'mymasters' => ['192.0.2.1', '198.51.100.1']
              },
              :zones => {
              'example.com' => { 'zone_type' => 'master' },
              'example.org' => { 'zone_type' => 'slave', 'slave_masters' => ['192.0.2.1', '198.51.100.1'] },
              },
              :includes => [ '/etc/myzones.conf' ],
              :server_id => '1',
              :key          => 'ddnskey',
              :allow_notify => ['1.1.1.1'],
              :forwarders   => ['8.8.8.8', '8.8.4.4'],
              :controls     => ['2.2.2.2', '3.3.3.3'],
              :secret       => 'ddnssecret',
            }
          }

          it 'should generate the bind configuration' do
            expect { should contain_file('/etc/named.conf')}
            content = catalogue.resource('file', '/etc/named.conf').send(:parameters)[:content]
            content.should match('acl rfc1918')
            content.should match('server-id "31"')
            content.should match('masters mymasters')
            content.should match('include "/etc/myzones.conf"')
            content.should match('ddnskey')
            content.should match('1.1.1.1')
            content.should match('2.2.2.2')
            content.should match('3.3.3.3')
            content.should match('8.8.8.8')
            content.should match('8.8.4.4')
            content.should_not match('hostname')
            content.should_not match('undef')
            content.should_not match('zone "example.com"')
          end

          case facts[:osfamily]
          when 'Debian'
            it 'should have concat resources for zones' do
              should contain_concat('/etc/bind/named.conf.local')
              should contain_concat__fragment('named.conf.local.example.com.include').with_content(/zone "example.com"/).with_target('/etc/bind/named.conf.local')
              should contain_concat__fragment('named.conf.local.example.org.include').with_content(/zone "example.org"/).with_target('/etc/bind/named.conf.local')
            end
          end
        end
      end
    end
  end
end