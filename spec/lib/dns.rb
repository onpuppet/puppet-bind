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

end
