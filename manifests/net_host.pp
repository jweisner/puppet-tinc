# tinc::net_host
define tinc::net_host(
  $member_nodes,
  $net_id,
  $prefixed_node_id = $name,
) {

  $node_id = regsubst($prefixed_node_id, "^${net_id}-", '')
  notify{ $node_id: }
}
