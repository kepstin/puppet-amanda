class amanda::server (
  $purge   = true,
  $config = {},
) {
  include amanda::params

  package { $::amanda::params::server_package:
    ensure => 'present',
    alias  => 'amanda-server',
  }

  file { $::amanda::params::configdir:
    ensure  => 'directory',
    owner   => $::amanda::params::user,
    group   => $::amanda::params::group,
    mode    => '0660',
    purge   => $purge,
    recurse => true,
    require => Package['amanda-server']
  }

  create_resources(amanda::config, $config)
}
