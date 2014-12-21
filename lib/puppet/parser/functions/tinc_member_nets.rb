Puppet::Parser::Functions::newfunction(:tinc_member_nets, :type => :rvalue, :doc => <<-EOF
This function takes two arguments (tinc_nets hash, and the node's puppet clientcert)
and returns an array of nets this node belongs to.
EOF
) do |args|
  raise Puppet::ParseError, "Wrong number of arguments" if args.to_a.length < 2 || args.to_a.length > 2
  tinc_nets = args.to_a[0]
  clientcert = args.to_s[1]

  raise Puppet::ParseError, "First argument must be a hash" unless tinc_nets.is_a?(Hash)
  raise Puppet::ParseError, "Second argument must be a string, got #{clientcert.class}" unless clientcert.is_a?(String)

  # remove items from tinc_nets missing a valid member_nodes hash
  tinc_nets.delete_if { |key,value| value['member_nodes'].class.to_s != 'Hash' }

  # make an array of tinc_nets with this node in the member_nodes hash
  member_nets = tinc_nets.keys.select { |key| tinc_nets[key]['member_nodes'].has_key?(clientcert) }

  return member_nets
end
