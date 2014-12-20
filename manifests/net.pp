# Tinc VPN net
#
define tinc::net(
  $nets,
  $net_id = $name,
){

  #TODO: extract all of the necessary template vars

  # file { "/etc/tinc/${net_id}":
  #   ensure  => 'directory',
  #   owner   => 'root',
  #   group   => 'root',
  #   mode    => '0750',
  #   purge   => true,
  #   recurse => true,
  #   notify  => Service['tinc'],
  # }->
  # file { "/etc/tinc/${net_id}/tinc-up":
  #   ensure  => 'file',
  #   owner   => 'root',
  #   group   => 'root',
  #   mode    => '0640',
  #   content => template('tinc/tinc-up.erb'),
  #   notify  => Service['tinc'],
  # }->
  # file { "/etc/tinc/${net_id}/tinc-down":
  #   ensure  => 'file',
  #   owner   => 'root',
  #   group   => 'root',
  #   mode    => '0640',
  #   content => template('tinc/tinc-down.erb'),
  #   notify  => Service['tinc'],
  # }->
  # file { "/etc/tinc/${net_id}/tinc.conf":
  #   ensure  => 'file',
  #   owner   => 'root',
  #   group   => 'root',
  #   mode    => '0640',
  #   content => template('tinc/tinc.conf.erb'),
  #   notify  => Service['tinc'],
  # }

  # file { "/etc/tinc/${net_id}/hosts":
  #   ensure  => 'directory',
  #   owner   => 'root',
  #   group   => 'root',
  #   mode    => '0750',
  #   purge   => true,
  #   recurse => true,
  #   notify  => Service['tinc'],
  # }

  $net_member_nodes   = $nets[$net_id]['member_nodes']
  $net_hosts_prefixed = prefix(keys($net_member_nodes), "${net_id}-")
  net_host{$net_hosts_prefixed:
    member_nodes => $net_member_nodes,
    net_id       => $net_id,
  }
}
