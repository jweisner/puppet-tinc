# tinc::net_host
define tinc::net_host(
  $member_nodes,
  $net_id,
  $prefixed_node_certname = $name,
) {

  $node_certname = regsubst($prefixed_node_certname, "^${net_id}-", '')
  $node_id       = $member_nodes[$node_certname]['node_id']

  file { "/etc/tinc/${net_id}/hosts/${node_id}":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => template('tinc/net_host.erb'),
  }
}
