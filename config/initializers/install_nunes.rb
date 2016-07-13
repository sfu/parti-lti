require 'statsd'
require 'resolv'
require 'nunes'
require 'socket'

# get server and namespace from the environment
statsd_server_addr = ENV["PARTI_STATSD_SERVER"] 
namespace_root = ENV["PARTI_STATSD_NAMESPACE_ROOT"] || 'parti'

if statsd_server_addr.nil? 
  Rails.logger.warn "WARNING: Environment variable PARTI_STATSD_SERVER not defined. Disabling statsd reporting."
else
  Rails.logger.info "PARTI_STATSD_SERVER=#{statsd_server_addr}"
  Rails.logger.info "PARTI_STATSD_NAMESPACE_ROOT=#{namespace_root}"

  fqdn = Socket.gethostname
  hostname = fqdn.split(".")[0] 
  namespace = namespace_root + '.' +  hostname

  # question about whether statsd caches dns lookup
  # so let's look it up ourselves
  resolver = Resolv::DNS.new()
  ip_address = resolver.getaddress(statsd_server_addr)
  ip_address_s = "#{ip_address}"

  statsd = Statsd.new(ip_address_s, 8125)
  statsd.namespace = namespace

  Nunes.subscribe(statsd)
end

