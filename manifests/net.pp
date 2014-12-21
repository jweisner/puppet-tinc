# Tinc VPN net
#
define tinc::net(
  $nets,
  $net_defaults,
  $net_id = $name,
){

  $net = merge($net_defaults, $nets[$net_id])
  $net_internal = split($net['internal_cidr'], '/')
  $net_internal_ip = $net_internal[0]
  $net_internal_mask = tinc_cidr_to_netmask($net_internal[1])

  $this_node = $net['member_nodes'][$::clientcert]

  $node_id               = $this_node['node_id']
  $device                = $this_node['device']
  $connectto             = any2array($this_node['connectto'])
  $node_internal         = split($this_node['internal_cidr'], '/')
  $node_internal_ip      = $node_internal[0]
  $node_internal_netmask = tinc_cidr_to_netmask($net_internal[1])

  file { "/etc/tinc/${net_id}":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    purge   => true,
    recurse => true,
  }->
  file { "/etc/tinc/${net_id}/tinc-up":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0550',
    content => template('tinc/tinc-up.erb'),
  }->
  file { "/etc/tinc/${net_id}/tinc-down":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0550',
    content => template('tinc/tinc-down.erb'),
  }->
  file { "/etc/tinc/${net_id}/tinc.conf":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => template('tinc/tinc.conf.erb'),
  }

  $key_source_path = $net['key_source_path']
  file { "/etc/tinc/${net_id}/rsa_key.priv":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => file("${key_source_path}/${net_id}/${::clientcert}/rsa_key.pub", 'tinc/missing'),
  }

  file { "/etc/tinc/${net_id}/hosts":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    purge   => true,
    recurse => true,
    force   => true,
  }

  $net_member_nodes   = $net['member_nodes']
  $net_nodes_prefixed = prefix(keys($net_member_nodes), "${net_id}-")
  # notify { 'member_net_nodes':
  #   message => inline_template("net_nodes_prefixed => <%= @net_nodes_prefixed.join(',') %>"),
  # }
  net_host{$net_nodes_prefixed:
    member_nodes    => $net_member_nodes,
    net_id          => $net_id,
    key_source_path => $net['key_source_path'],
  }
}
