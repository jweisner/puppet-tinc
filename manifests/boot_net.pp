#
define tinc::boot_net(
  $net_id = $name,
){
  file_line { "tinc-boot-${net_id}":
    ensure => present,
    path   => '/etc/tinc/nets.boot',
    line   => $net_id,
  }
}
