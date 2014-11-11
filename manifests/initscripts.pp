# == Class: irqbalance::initscripts
#
# Class to install init scripts for irqbalance
#
class irqbalance::initscripts inherits irqbalance {

  # If the init script file gets replaced, systemd needs to run daemon-reload.
  # Upstart uses inotify to detect init file changes and SysV-like Inits don't
  # care
  $init_reload_exec = $irqbalance::service_provider ? {
        'systemd' => 'systemd_daemon_reload',
        default   => 'noop_init_file_change',
      }

  if $irqbalance::manage_init_script_file {

    if $irqbalance::init_script_file_source {

      file { $irqbalance::init_script_file_path:
        ensure => file,
        source => $irqbalance::init_script_file_source,
        group  => $irqbalance::init_script_file_group,
        mode   => $irqbalance::init_script_file_mode,
        owner  => $irqbalance::init_script_file_owner,
        notify => Exec[$init_reload_exec],
      }

    }

    elsif $irqbalance::init_script_file_template {

      file { $irqbalance::init_script_file_path:
        ensure  => file,
        content => template($irqbalance::init_script_file_template),
        group   => $irqbalance::init_script_file_group,
        mode    => $irqbalance::init_script_file_mode,
        owner   => $irqbalance::init_script_file_owner,
        notify  => Exec[$init_reload_exec],
      }

    }

    # No source or template has been provided.
    # Only the file permissions of the init script will be managed.

    else {

      exec { 'check_init_script_presence':
        command => '/bin/false',
        unless  => "/usr/bin/test -e ${irqbalance::init_script_file_path}",
      }

      file { $irqbalance::init_script_file_path:
        ensure  => file,
        group   => $irqbalance::init_script_file_group,
        mode    => $irqbalance::init_script_file_mode,
        owner   => $irqbalance::init_script_file_owner,
        require => Exec['check_init_script_presence'],
      }

    }

  }

  exec { 'systemd_daemon_reload':
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  exec { 'noop_init_file_change':
    command     => '/bin/true',
    refreshonly => true,
  }

}

