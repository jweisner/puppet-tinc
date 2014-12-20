# URL: https://github.com/jweisner/puppet-tinc_wrapper.git
# Author: Jesse Weisner <jesse@weisner.ca>
# License: Apache 2.0
class tinc(
  $net_defaults       = {},
  $net_defaults_merge = true,
  $nets               = {},
  $nets_merge         = true,
  $package_list       = {'tinc' => {ensure => installed} },
  $service_name       = 'tinc',
  $service_enable     = true,
  $service_ensure     = 'running',
){
  create_resources('package', $package_list)
  $package_array = keys($package_list)

  file { '/etc/tinc':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0550',
    purge   => true,
    recurse => true,
  }->
  file { '/etc/tinc/nets.boot':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => '### WARNING: This file is controlled by Puppet ###',
  }->
  service { $service_name:
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => Package[$package_array],
  }

  $net_defaults_override = $net_defaults_merge? {
    false   => $net_defaults,
    default => hiera_hash('tinc::net_defaults', $net_defaults)
  }

  $net_defaults_all = {
    ensure         => present,
    connectto      => [],
    device         => '/dev/net/tun',
    mode           => 'router',
    net_enable     => true,
    node_id        => $::hostname,
    port           => '655',
  }

  $net_defaults_real = merge($net_defaults_all, $net_defaults_override)

  $nets_real = $nets_merge? {
    false   => $nets,
    default => hiera_hash('tinc::nets', $nets),
  }
}
