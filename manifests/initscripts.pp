# == Class: irqbalance::initscripts
#
# Class to install init scripts for irqbalance
#
class irqbalance::initscripts inherits irqbalance {

  if ($irqbalance::prefer_default_init_script == false) {

    if ($irqbalance::init_file_source) {

      file { $irqbalance::init_file_path:
        ensure => file,
        source => $irqbalance::init_file_source,
        group  => $irqbalance::init_file_group,
        mode   => $irqbalance::init_file_mode,
        owner  => $irqbalance::init_file_owner,
      }

    }

    elsif ($irqbalance::init_template) {

      file { $irqbalance::init_file_path:
        ensure  => file,
        content => template($irqbalance::init_template),
        group   => $irqbalance::init_file_group,
        mode    => $irqbalance::init_file_mode,
        owner   => $irqbalance::init_file_owner,
      }

    }

  }

}