# tinc::puppetmaster_net_host
#
# - creates a subfolder for each clientcert name in the Tinc net
# - creates a 2048-bit RSA private key for each clientcert
# - creates an RSA public key for each clientcert

define tinc::puppetmaster_net_host (
  $key_source_path,
  $net,
  $net_id,
  $prefixed_node_certname = $name,
) {

  $node_certname = regsubst($prefixed_node_certname, "^${net_id}-", '')

  file { "${key_source_path}/${net_id}/${node_certname}":
    ensure  => 'directory',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0700',
    require => File["${key_source_path}/${net_id}"]
    # not purging here for now
  }

  $private_key_path = "${key_source_path}/${net_id}/${node_certname}/rsa_key.priv"
  $public_key_path  = "${key_source_path}/${net_id}/${node_certname}/rsa_key.pub"

  exec { "${prefixed_node_certname}-private":
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    command => "openssl genrsa -out ${private_key_path} 2048",
    creates => $private_key_path,
    require => File["${key_source_path}/${net_id}/${node_certname}"],
    notify  => Exec["${prefixed_node_certname}-cleanpub"],
  }->
  exec { "${prefixed_node_certname}-public":
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    command => "openssl rsa -in ${private_key_path} -pubout -out ${public_key_path}",
    creates => $public_key_path,
    require => [
      File["${key_source_path}/${net_id}/${node_certname}"],
      Exec["${prefixed_node_certname}-cleanpub"],
    ],
  }

  # make sure there is no stray public key when generating new private key
  exec { "${prefixed_node_certname}-cleanpub":
    path        => '/bin:/sbin:/usr/bin:/usr/sbin',
    command     => "rm -f ${public_key_path}",
    refreshonly => true,
  }
}
