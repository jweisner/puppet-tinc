require 'ipaddr'

Puppet::Parser::Functions::newfunction(:tinc_cidr_to_netmask, :type => :rvalue, :doc => <<-EOF
This function takes a CIDR prefix (24) and returns a dotted netmask (255.255.255.0)
EOF
) do |args|
  raise Puppet::ParseError, "Wrong number of arguments" if args.to_a.length != 1
  cidr  = args.to_a[0].to_i

  netmask = IPAddr.new('255.255.255.255').mask(cidr).to_s

  return netmask
end
