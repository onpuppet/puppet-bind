require 'resolv'

class Nsupdate
  def initialize(server, dns_key)
    @dns_key = dns_key
    @server = server
  end

  # create({ :fqdn => "node01.lab", :value => "192.168.100.2"}
  # create({ :fqdn => "node01.lab", :value => "3.100.168.192.in-addr.arpa",
  #          :type => "PTR"}
  def create(fqdn, value, type, ttl=600, priority=10)
    nsupdate "connect"

    @resolver = Resolv::DNS.new(:nameserver => @server)
    case type
    when "A"
      nsupdate "update add #{fqdn}. #{ttl} #{type} #{value}"
    when "CNAME"
      nsupdate "update add #{fqdn}. #{ttl} #{type} #{value}."
    when "PTR"
      reverse_ip = fqdn.split(".").reverse.join(".") + ".IN-ADDR.ARPA"
      nsupdate "update add #{reverse_ip}. #{ttl} #{type} #{value}."
    when "NS"
      nsupdate "zone #{fqdn}"
      nsupdate "update add #{fqdn} 0 IN #{type} #{value}"
    when "MX"
      nsupdate "update add #{fqdn} #{ttl} #{type} #{priority} #{value}."
    end
    nsupdate "disconnect"
  ensure
    @om.close unless @om.nil? or @om.closed?
  end

  # remove({ :fqdn => "node01.lab", :value => "192.168.100.2"}
  def remove
    nsupdate "connect"
    case @type
    when "A"
      nsupdate "update delete #{@fqdn} #{@type}"
    when "PTR"
      nsupdate "update delete #{@value} #{@type}"
    end
    nsupdate "disconnect"
  end

  protected

  def nsupdate_args
    args = ""
    args = "-k #{@dns_key} " if @dns_key
    args
  end

  def nsupdate cmd
    status = nil
    if cmd == "connect"
      find_nsupdate if @nsupdate.nil?
      nsupdate_cmd = "#{@nsupdate} #{nsupdate_args}"
      #      logger.debug "running #{nsupdate_cmd}"
      STDOUT.write "running #{nsupdate_cmd}\n"
      @om = IO.popen(nsupdate_cmd, "r+")
      #      logger.debug "nsupdate: executed - server #{@server}"
      STDOUT.write "nsupdate: executed - server #{@server}\n"
      @om.puts "server #{@server}"
    elsif cmd == "disconnect"
      @om.puts "send"
      @om.puts "answer"
      @om.close_write
      status = @om.readlines
      @om.close
      @om = nil # we cannot serialize an IO object, even if closed.
      # TODO Parse output for errors!
      if !status.empty? and status[1] !~ /status: NOERROR/
        #        logger.debug "nsupdate: errors\n" + status.join("\n")
        #        raise Proxy::Dns::Error.new("Update errors: #{status.join("\n")}")
        raise "Update errors: #{status.join("\n")}"
      end
    else
      STDOUT.write "nsupdate: executed - #{cmd}\n"
      #      logger.debug "nsupdate: executed - #{cmd}"
      @om.puts cmd
    end
  end

  private

  def find_nsupdate
    @nsupdate = which("nsupdate")
    unless File.exists?("#{@nsupdate}")
      #      logger.warn "unable to find nsupdate binary, maybe missing bind-utils package?"
      raise "unable to find nsupdate binary"
    end
  end

  def dns_find key
    if match = key.match(/(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/)
      resolver.getname(match[1..4].reverse.join(".")).to_s
    else
      resolver.getaddress(key).to_s
    end
  rescue Resolv::ResolvError
    false
  end

  def which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each { |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable?(exe) && !File.directory?(exe)
      }
    end
    return nil
  end
end
