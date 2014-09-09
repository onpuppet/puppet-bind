# puppet-bind

## Overview
  
Install and enable a BIND DNS server, manage its main configuration and install
and manage its DNS zone files.

# Example bind master slave setup

```puppet
node master {
	class { 'bind': 
	          allow_notify      => [ '#{slave_ipv4}' ] 
	        }
	        
	        bind::zone { 'example.com':
	          nameservers    => ['ns1.example.com', 'ns2.example.com'],
	          allow_transfer => [ '#{slave_ipv4}' ],
	        }
	  
	        bind::zone { '12.168.192.IN-ADDR.ARPA':
	          nameservers    => ['ns1.example.com', 'ns2.example.com'],
	          allow_transfer => [ '#{slave_ipv4}' ],
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
	  }
}

node slave {
          class { 'bind': 
            masters => { 'masterlist' => [ '#{master_ipv4}' ] }
          }
}
```


## TESTING

    # Ubuntu 14.04
    apt-get install libxslt-dev bundler -y
    bundle install
    curl -sSL https://get.docker.io/ubuntu/ | sudo sh
    sudo usermod -G docker jenkins
    bundle exec rake test
    bundle exec rake acceptance
