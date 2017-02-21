require 'spec_helper'

describe 'bind' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:title) { 'bind' }
        let(:parser) { 'future' }
        let(:node) { 'rspec.node1' }
        let(:facts) do
          facts.merge(
            ipaddress: '10.0.0.10',
            concat_basedir: '/tmp'
          )
        end
        let(:params) { { :config_file => '/etc/bind/named.conf', :package => 'bind', 'servicename' => 'bind' } }

        describe 'Test that catalogue compiles' do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('bind') }
        end

        describe 'Test standard installation' do
          it { is_expected.to contain_package('bind').with_ensure('present') }
          it { is_expected.to contain_service('bind').with_ensure('running') }
          it { is_expected.to contain_service('bind').with_enable(true) }
          it { is_expected.to contain_service('bind').with_hasstatus(true) }
          it { is_expected.to contain_file('/etc/bind/named.conf') }
          case facts[:osfamily]
          when 'RedHat'
            it 'creates the logging directory' do
              is_expected.to contain_file('/var/log/named').with(
                'ensure' => 'directory',
                'owner' => 'root',
                'group' => 'named',
                'mode' => '0770',
                'seltype' => 'var_log_t'
              )
            end
          when 'Debian'
            it 'creates the logging directory' do
              is_expected.to contain_file('/var/log/named').with(
                'ensure' => 'directory',
                'owner' => 'bind',
                'group' => 'bind',
                'mode' => '0770',
                'seltype' => 'var_log_t'
              )
            end
          end
        end

        describe 'Test installation with custom config and zones' do
          let(:params) do
            {
              config_file: '/etc/named.conf',
              acls: {
                'rfc1918' => ['10/8', '172.16/12', '192.168/16']
              },
              masters: {
                'mymasters' => ['192.0.2.1', '198.51.100.1']
              },
              zones: {
                'example.com' => { 'zone_type' => 'master' },
                'example.org' => { 'zone_type' => 'slave', 'slave_masters' => ['192.0.2.1', '198.51.100.1'] }
              },
              includes: ['/etc/myzones.conf'],
              server_id: '1',
              key: 'ddnskey',
              allow_notify: ['1.1.1.1'],
              forwarders: ['8.8.8.8', '8.8.4.4'],
              controls: ['2.2.2.2', '3.3.3.3'],
              secret: 'ddnssecret'
            }
          end

          it 'generates the bind configuration' do
            is_expected.to contain_file('/etc/named.conf')
            content = catalogue.resource('file', '/etc/named.conf').send(:parameters)[:content]
            expect { content.should match('acl rfc1918') }
            expect { content.should match('server-id "31"') }
            expect { content.should match('masters mymasters') }
            expect { content.should match('include "/etc/myzones.conf"') }
            expect { content.should match('ddnskey') }
            expect { content.should match('1.1.1.1') }
            expect { content.should match('2.2.2.2') }
            expect { content.should match('3.3.3.3') }
            expect { content.should match('8.8.8.8') }
            expect { content.should match('8.8.4.4') }
            expect { content.should_not match('hostname') }
            expect { content.should_not match('undef') }
            expect { content.should_not match('zone "example.com"') }
          end

          case facts[:osfamily]
          when 'Debian'
            it 'has concat resources for zones' do
              is_expected.to contain_concat('/etc/bind/named.conf.local')
              is_expected.to contain_concat__fragment('named.conf.local.example.com.include').with_content(%r{zone "example.com"}).with_target('/etc/bind/named.conf.local')
              is_expected.to contain_concat__fragment('named.conf.local.example.org.include').with_content(%r{zone "example.org"}).with_target('/etc/bind/named.conf.local')
            end
          end
        end
      end
    end
  end
end
