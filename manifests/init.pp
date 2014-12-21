# URL: https://github.com/jweisner/puppet-tinc_wrapper.git
# Author: Jesse Weisner <jesse@weisner.ca>
# License: Apache 2.0
class tinc(
  $net_defaults       = {},
  $net_defaults_merge = true,
  $nets               = {},
  $nets_merge         = true,
  $node_id            = regsubst($::hostname,'[._-]+','','G'),
  $package_list       = {'tinc' => {ensure => installed} },
  $service_name       = 'tinc',
  $service_enable     = false,     ### TEMPORARY FOR DEBUGGING
  $service_ensure     = 'stopped', ### TEMPORARY FOR DEBUGGING
){
  create_resources('package', $package_list)
  $package_array = keys($package_list)

  $test_netmask = tinc_cidr_to_netmask('29')

  file { '/etc/sysconfig/tinc':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/tinc/tinc.sysconfig',
  }

  file { '/etc/init.d/tinc':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/tinc/tinc.init',
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
    key_source_path => '/var/lib/puppet/tinc',
  }

  $net_defaults_real = merge($net_defaults_builtin, $net_defaults_hiera)

  # notify { 'net_defaults_real:':
  #   message => join(keys($net_defaults_real), ', ')
  # }

  $nets_real = $nets_merge? {
    false   => $nets,
    default => hiera_hash('tinc::nets', $nets),
  }

  # notify { 'node_id':
  #   message => "node_id => ${node_id}",
  # }

  # notify { 'nets':
  #   message => inline_template("nets => <%= @nets_real.keys.join(',') %>"),
  # }

  # notify { 'nets_real':
  #   message => join(keys($nets_real['ptrpe']), ' ')
  # }
  # notify { "clientcert => ${::clientcert}": }

  $member_nets = tinc_member_nets($nets_real, $::clientcert)
  # notify { 'member_nets':
  #   message => inline_template("member_nets => <%= @member_nets.join(',') %>"),
  # }

  net { $member_nets:
    net_defaults => $net_defaults_real,
    nets         => $nets_real
  }
  boot_net { $member_nets: }
}
