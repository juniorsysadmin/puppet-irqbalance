# == Class: irqbalance::config
#
class irqbalance::config inherits irqbalance {

  if ($irqbalance::config_file_source) {

    file { "${irqbalance::config_dir_path}/${irqbalance::config_file_name}":
      ensure => file,
      source => $irqbalance::config_file_source,
      group  => $irqbalance::config_file_group,
      mode   => $irqbalance::config_file_mode,
      owner  => $irqbalance::config_file_owner,
    }

  }

  else {

    file { "${irqbalance::config_dir_path}/${irqbalance::config_file_name}":
      ensure  => file,
      content => template($irqbalance::config_file_template),
      group   => $irqbalance::config_file_group,
      mode    => $irqbalance::config_file_mode,
      owner   => $irqbalance::config_file_owner,
    }

  }

}
