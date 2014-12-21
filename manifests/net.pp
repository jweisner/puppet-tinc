# Tinc VPN net
# Author: Jesse Weisner <jesse@weisner.ca>
# License: Apache 2.0
define tinc::net(
  $key_source_path,
  $nets,
  $net_defaults,
  $net_id       = $name,
  $service_name = 'tinc',
){

  $net = merge($net_defaults, $nets[$net_id])
  $net_internal = split($net['internal_cidr'], '/')
  $net_internal_ip = $net_internal[0]
  $net_internal_mask = tinc_cidr_to_netmask($net_internal[1])

  $this_node = $net['member_nodes'][$::clientcert]

  $node_id               = $this_node['node_id']
  $device                = pick($this_node['device'], $net['device'], '/dev/net/tun')
  $net_connectto         = any2array($net['connectto'])
  $node_connectto        = any2array($this_node['connectto'])
  $connectto_merged      = unique(concat($net_connectto, $node_connectto))
  $connectto             = delete($connectto_merged, $node_id)
  $node_internal         = split($this_node['internal_cidr'], '/')
  $node_internal_ip      = $node_internal[0]
  $node_internal_netmask = tinc_cidr_to_netmask($net_internal[1])
  $node_port             = pick($this_node['port'], $net['port'], 'none')

  file { "/etc/tinc/${net_id}":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    purge   => true,
    recurse => true,
    notify  => Service[$service_name],
  }->
  file { "/etc/tinc/${net_id}/tinc-up":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0550',
    content => template('tinc/tinc-up.erb'),
    notify  => Service[$service_name],
  }->
  file { "/etc/tinc/${net_id}/tinc-down":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0550',
    content => template('tinc/tinc-down.erb'),
    notify  => Service[$service_name],
  }->
  file { "/etc/tinc/${net_id}/tinc.conf":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => template('tinc/tinc.conf.erb'),
    notify  => Service[$service_name],
  }

  file { "/etc/tinc/${net_id}/rsa_key.priv":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => file("${key_source_path}/${net_id}/${::clientcert}/rsa_key.pub", 'tinc/missing'),
    notify  => Service[$service_name],
  }

  file { "/etc/tinc/${net_id}/hosts":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    purge   => true,
    recurse => true,
    force   => true,
    notify  => Service[$service_name],
  }

  $net_member_nodes   = $net['member_nodes']
  $net_nodes_prefixed = prefix(keys($net_member_nodes), "${net_id}-")

  net_host{$net_nodes_prefixed:
    member_nodes    => $net_member_nodes,
    net_id          => $net_id,
    net             => $net,
    key_source_path => $key_source_path,
    service_name    => $service_name,
  }
}
