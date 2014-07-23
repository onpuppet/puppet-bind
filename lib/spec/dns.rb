require 'rubygems'
require 'resolv'
require 'ipaddress'

class DNS
  # ip_address = dotted notation as a string, e.g. '192.168.1.1'
  # role = 'Master' or 'Slave'
  # domain_name = the domain name as a string, e.g. 'sharknet.us'
  def initialize(ip_address, role, domain_name)
    @role = role
    @ip_address = ip_address
    @resolver = Resolv::DNS.new(
    :nameserver => [ip_address],
    :search => [domain_name],
    :ndots => 1)
    # @resolver.timeouts = 2 # Enable for Ruby 2.1 or newer. Fail if lookup takes longer than 2 seconds
  end

  # returns the ip address string
  def name
    @ip_address
  end

  # returns the role string
  def role
    @role
  end

  # returns the DNS server as a string in the form '192.168.1.1 [Master]'
  def to_s
    "#{name} [#{role}]"
  end

  # returns the ip address as a string or 'Hostname not found' if there was any error
  def address( hostname )
    begin
      @resolver.getaddress( hostname ).to_s
    rescue
      'Hostname not found'
    end
  end

  # returns the hostname as a string or 'IP address not found' if there was any error
  def hostname( ip_address )
    begin
      @resolver.getname( ip_address ).to_s
    rescue
      'IP address not found'
    end
  end

  # return true if ip is between (inclusive) ip_address_start and ip_address_end
  # ip_address_start and ip_address_end use CIDR notation; e.g., '192.168.1.1/24'
  # All the addresses must be passed as strings
  def host_in_range?( ip, ip_address_start, ip_address_end )
    return ip >= ip_address_start && ip <= ip_address_end
  end

  def is_host?( hostname, ip_address )
    records = @resolver.getresources( hostname, Resolv::DNS::Resource::IN::A )
    records.each do |record|
      if record.address.to_s == ip_address
        return true
      end
    end
    return false
  end

  def is_pointer?( ip_address, hostname )
    if hostname( ip_address ) == hostname
      return true
    end
    return false
  end

  def is_mail_server?( domain_name, hostname, preference )
    mx_records = @resolver.getresources( domain_name, Resolv::DNS::Resource::IN::MX )
    mx_records.each do |record|
      if record.exchange.to_s == hostname && record.preference == preference
        return true
      end
    end
    return false
  end

  def is_nameserver?( domain_name, hostname )
    mx_records = @resolver.getresources( domain_name, Resolv::DNS::Resource::IN::NS )
    mx_records.each do |record|
      if record.name.to_s == hostname
        return true
      end
    end
    return false
  end

  def is_alias?( hostname, host_alias )
    mx_records = @resolver.getresources( hostname, Resolv::DNS::Resource::IN::CNAME )
    mx_records.each do |record|
      if record.name.to_s == host_alias
        return true
      end
    end
    return false
  end

end
