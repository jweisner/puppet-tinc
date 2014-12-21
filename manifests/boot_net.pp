### Warning: This file is controlled by Puppet ###
define tinc::boot_net(
  $net_id       = $name,
  $service_name = 'tinc',
){
  file_line { "tinc-boot-${net_id}":
    ensure => present,
    path   => '/etc/tinc/nets.boot',
    line   => $net_id,
    notify => Service[$service_name],
  }
}
