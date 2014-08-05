# == Class: irqbalance::config
#
class irqbalance::config inherits irqbalance {

  if ($irqbalance::config_file_source) {

    file { $irqbalance::config:
      ensure  => file,
      source  => $irqbalance::config_file_source,
      group   => $irqbalance::config_file_group,
      mode    => $irqbalance::config_file_mode,
      owner   => $irqbalance::config_file_owner,
    }

  }

  else {

    file { $irqbalance::config:
      ensure  => file,
      content => template($irqbalance::config_template),
      group   => $irqbalance::config_file_group,
      mode    => $irqbalance::config_file_mode,
      owner   => $irqbalance::config_file_owner,
    }

  }

}