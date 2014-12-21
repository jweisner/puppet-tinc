# Tinc VPN net
#
define tinc::net(
  $nets,
  $net_id = $name,
){

  $node_internal_ip      = '***MAGIC***'
  $node_internal_netmask = '***MAGIC***'

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

  $key_source_path = $nets[$net_id]['key_source_path']
  notify{ "${net_id} key_source_path = ${key_source_path}": }
  file { "/etc/tinc/${net_id}/rsa_key.priv":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => file("${key_source_path}/${net_id}/${::clientcert}/rsa_key.pub"),
  }

  file { "/etc/tinc/${net_id}/hosts":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    purge   => true,
    recurse => true,
  }

  $net_member_nodes   = $nets[$net_id]['member_nodes']
  $net_nodes_prefixed = prefix(keys($net_member_nodes), "${net_id}-")
  # notify { 'member_net_nodes':
  #   message => inline_template("net_nodes_prefixed => <%= @net_nodes_prefixed.join(',') %>"),
  # }
  net_host{$net_nodes_prefixed:
    member_nodes    => $net_member_nodes,
    net_id          => $net_id,
    key_source_path => $nets[$net_id]['key_source_path'],
  }
}
