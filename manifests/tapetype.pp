define amanda::tapetype (
  $tapetype_name = $name,
  $config        = 'daily',
  $filemark      = undef,
  $inherit       = [],
  $length        = undef,
  $order         = undef,
  $extra_config  = {},
) {
  include amanda::params
  include amanda::server

  validate_re($tapetype_name, $::amanda::params::name_re)
  validate_re($config, $::amanda::params::config_re)
  validate_array($inherit)
  validate_hash($extra_config)

  if $order {
    $real_order = $order
  } else {
    $real_order = $::amanda::params::tapetype_order
  }

  concat::fragment { "amanda::tapetype::${name}":
    target  => "${::amanda::params::configdir}/${config}/amanda.conf",
    content => template("amanda/amanda.conf/tapetype.erb"),
    order   => $real_order,
  }
}
