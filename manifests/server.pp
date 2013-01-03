class amanda::server {
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
    recurse => true,
    force   => true,
    require => Package['amanda-server']
  }
}
