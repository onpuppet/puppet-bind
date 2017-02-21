require 'rubygems'
require 'resolv'
require 'ipaddress'

class DNS
  attr_reader :role, :ip_address

  # ip_address = dotted notation as a string, e.g. '192.168.1.1'
  # role = 'Master' or 'Slave'
  # domain_name = the domain name as a string, e.g. 'sharknet.us'
  def initialize(ip_address, role, domain_name)
    @role = role
    @ip_address = ip_address
    @resolver = Resolv::DNS.new(
      nameserver: [ip_address],
      search: [domain_name],
      ndots: 1
    )
    @resolver.timeouts = 2 # Enable for Ruby 2.1 or newer. Fail if lookup takes longer than 2 seconds
  end

  # returns the DNS server as a string in the form '192.168.1.1 [Master]'
  def to_s
    "#{ip_address} [#{role}]"
  end

  # returns the ip address as a string or 'Hostname not found' if there was any error
  def address(hostname)
    @resolver.getaddress(hostname).to_s
  rescue
    'Hostname not found'
  end

  # returns the hostname as a string or 'IP address not found' if there was any error
  def hostname(ip_address)
    @resolver.getname(ip_address).to_s
  rescue
    'IP address not found'
  end

  # return true if ip is between (inclusive) ip_address_start and ip_address_end
  # ip_address_start and ip_address_end use CIDR notation; e.g. '192.168.1.1/24'
  # All the addresses must be passed as strings
  def host_in_range?(ip, ip_address_start, ip_address_end)
    ip >= ip_address_start && ip <= ip_address_end
  end

  def host?(hostname, ip_address)
    records = @resolver.getresources(hostname, Resolv::DNS::Resource::IN::A)
    records.each do |record|
      return true if record.address.to_s == ip_address
    end
    false
  end

  def host_ipv6?(hostname, ip_address)
    records = @resolver.getresources(hostname, Resolv::DNS::Resource::IN::AAAA)
    records.each do |record|
      return true if record.address.to_s.casecmp(ip_address)
    end
    false
  end

  def pointer?(hostname, ip_address)
    # Using dig due to:
    # https://stackoverflow.com/questions/27060993/resolvdns-not-resolving-ptr-for-192-168-x
    resolved_hostname = `/usr/bin/dig @#{@ip_address} -x #{ip_address} +short`
    return true if resolved_hostname.delete("\n") == "#{hostname}."
    false
  end

  def mail_server?(domain_name, hostname, preference)
    mx_records = @resolver.getresources(domain_name,
                                        Resolv::DNS::Resource::IN::MX)
    mx_records.each do |record|
      return true if record.exchange.to_s == hostname &&
                     record.preference == preference
    end
    false
  end

  def nameserver?(domain_name, hostname)
    ns_records = @resolver.getresources(domain_name,
                                        Resolv::DNS::Resource::IN::NS)
    ns_records.each do |record|
      STDOUT.write 'NS: ' + record.name.to_s + '==' + hostname
      return true if record.name.to_s == hostname
    end
    false
  end

  def alias?(hostname, host_alias)
    records = @resolver.getresources(hostname, Resolv::DNS::Resource::IN::CNAME)
    records.each do |record|
      return true if record.name.to_s == host_alias
    end
    false
  end
end
