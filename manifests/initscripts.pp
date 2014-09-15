# == Class: irqbalance::initscripts
#
# Class to install init scripts for irqbalance
#
class irqbalance::initscripts inherits irqbalance {

  if ($irqbalance::manage_init_script_file) {

    if ($irqbalance::init_script_file_source) {

      file { $irqbalance::init_script_file_path:
        ensure => file,
        group  => $irqbalance::init_script_file_group,
        mode   => $irqbalance::init_script_file_mode,
        owner  => $irqbalance::init_script_file_owner,
        source => $irqbalance::init_script_file_source,
      }

    }

    else {

      file { $irqbalance::init_script_file_path:
        ensure  => file,
        content => template($irqbalance::init_script_file_template),
        group   => $irqbalance::init_script_file_group,
        mode    => $irqbalance::init_script_file_mode,
        owner   => $irqbalance::init_script_file_owner,
      }

    }

  }

}
