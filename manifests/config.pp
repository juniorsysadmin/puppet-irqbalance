# == Class: irqbalance::config
#
class irqbalance::config inherits irqbalance {

    file { $irqbalance::config:
      ensure  => file,
      content => $irqbalance::config_file_src,
      group   => $irqbalance::config_file_group,
      mode    => $irqbalance::config_file_mode,
      owner   => $irqbalance::config_file_owner,
    }
}