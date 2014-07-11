require 'spec_helper_acceptance'

describe 'bind class' do


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
    case fact('operatingsystem')
    when 'OpenSuSE'
      package_name = 'named'
      service_name = 'named'
      service_provider = 'undef'
    when 'SLES'
      package_name = 'named'
      service_name = 'named'
      service_provider = 'undef'
    end
  when 'Debian'
   case fact('operatingsystem')
   when 'Debian'
    package_name = 'bind'
    service_name = 'named'
    service_provider = 'undef'
  when 'Ubuntu'
    package_name = 'bind9'
    service_name = 'named'
    service_provider = 'upstart'
  end

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOS
         class { 'bind': }
      EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    describe package(package_name) do
      it { should be_installed }
    end

    describe service(service_name) do
      it { should be_running }
      it { should be_enabled }
    end

  end
end

