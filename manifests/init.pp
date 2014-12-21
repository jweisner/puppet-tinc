# URL: https://github.com/jweisner/puppet-tinc_wrapper.git
# Author: Jesse Weisner <jesse@weisner.ca>
# License: Apache 2.0
class tinc(
  $key_source_path    = '/var/lib/puppet/tinc',
  $manage_init        = true,
  $net_defaults       = {},
  $net_defaults_merge = true,
  $nets               = {},
  $nets_merge         = true,
  $node_id            = regsubst($::hostname,'[._-]+','','G'),
  $package_list       = {'tinc' => {ensure => installed} },
  $service_name       = 'tinc',
  $service_enable     = true,
  $service_ensure     = 'running',
){
  create_resources('package', $package_list)
  $package_array = keys($package_list)

  file { '/etc/sysconfig/tinc':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/tinc/tinc.sysconfig',
    notify => Service[$service_name],
  }

  file { '/etc/init.d/tinc':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/tinc/tinc.init',
    notify => Service[$service_name],
  }~>
  exec { 'tinc-chkconfig':
    command     => 'chkconfig --add tinc',
    path        => ['/bin', '/sbin', '/usr/bin', '/usr/sbin'],
    refreshonly => true,
    unless      => 'chkconfig --list | grep -q tinc'
  }

  file { '/etc/tinc':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0550',
    purge   => true,
    recurse => true,
    force   => true,
  }->
  file { '/etc/tinc/nets.boot':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => "### WARNING: This file is controlled by Puppet ###\n",
    replace => false,
  }~>
  service { $service_name:
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => [
      Package[$package_array],
      File[
        '/etc/tinc/nets.boot',
        '/etc/init.d/tinc',
        '/etc/sysconfig/tinc'
      ]
    ],
  }

  $net_defaults_hiera = $net_defaults_merge? {
    false   => $net_defaults,
    default => hiera_hash('tinc::net_defaults', $net_defaults)
  }

  $net_defaults_builtin = {
    ensure          => present,
    connectto       => [],
    device          => '/dev/net/tun',
    mode            => 'router',
    net_enable      => true,
    node_id         => regsubst($::hostname,'[.-]+','','G'),
    port            => '655',
  }

  $net_defaults_real = merge($net_defaults_builtin, $net_defaults_hiera)

  $nets_real = $nets_merge? {
    false   => $nets,
    default => hiera_hash('tinc::nets', $nets),
  }

  $member_nets = tinc_member_nets($nets_real, $::clientcert)

  net { $member_nets:
    net_defaults    => $net_defaults_real,
    nets            => $nets_real,
    service_name    => $service_name,
    key_source_path => $key_source_path,
  }

  boot_net { $member_nets:
    service_name => $service_name,
  }
}
