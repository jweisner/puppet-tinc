# tinc::puppetmaster
#
# manage tinc key generation and access
# Author: Jesse Weisner <jesse@weisner.ca>
# License: Apache 2.0
class tinc::puppetmaster (){
  $key_source_path = pick(hiera('tinc::key_source_path'), '/var/lib/puppet/tinc')
  $nets            = pick(hiera_hash('tinc::nets'), {})
  $nets_list       = keys($nets)

  file { $key_source_path:
    ensure => 'directory',
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0700',
    # not purging for now
  }

  puppetmaster_net{$nets_list:
    key_source_path => $key_source_path,
    nets            => $nets,
  }
}
