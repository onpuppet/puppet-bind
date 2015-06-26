source "https://rubygems.org"

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.6.0'
  gem "puppet-lint"
  gem "puppet-lint-trailing_newline-check"
  gem "puppet-lint-variable_contains_upcase"
  gem "puppet-lint-param-docs"
  gem "puppet-lint-absolute_template_path"
  gem "puppet-lint-unquoted_string-check"
  gem "puppet-lint-strict_indent-check"
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
  gem "ci_reporter_rspec"
end

group :development do
  gem "travis"
  gem "travis-lint"
  gem "beaker"
  gem "beaker-rspec"
  gem "docker-api", 1.16
  gem "vagrant-wrapper"
  gem "puppet-blacksmith"
  gem "guard-rake"
end
