# tinc::net_host
define tinc::net_host(
  $key_source_path,
  $member_nodes,
  $net_id,
  $prefixed_node_certname = $name,
) {

  $node_certname = regsubst($prefixed_node_certname, "^${net_id}-", '')
  $node_id       = $member_nodes[$node_certname]['node_id']
  $external_ip   = $member_nodes[$node_certname]['external_ip']
  $internal_cidr = $member_nodes[$node_certname]['internal_cidr']
  $public_key    = file("${key_source_path}/${net_id}/${node_certname}/rsa_key.pub", 'tinc/missing')

  file { "/etc/tinc/${net_id}/hosts/${node_id}":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => template('tinc/net_host.erb'),
  }
}
