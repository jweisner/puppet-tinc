# tinc::puppetmaster_net
#
# - creates a subfolder under $key_source_path for each Tinc net
# - instantiates puppetmaster_net_host for each member_node
define tinc::puppetmaster_net (
  $key_source_path,
  $nets,
  $net_id = $name,
) {

  file {"${key_source_path}/${net_id}":
    ensure => 'directory',
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0700',
    # not going to purge contents here, maybe
  }

  $members          = keys($nets[$net_id]['member_nodes'])
  $members_prefixed = prefix($members, "${net_id}-")

  puppetmaster_net_host { $members_prefixed:
    key_source_path => $key_source_path,
    net             => $nets[$net_id],
    net_id          => $net_id,
  }
}
