# == Class: irqbalance::initscripts
#
# Module to install custom initscripts for irqbalance.
#
class irqbalance::initscripts inherits irqbalance {

  case $irqbalance::service_provider {
    'debian': {
      $init_file_group  = $irqbalance::sysv_file_group
      $init_file_mode   = $irqbalance::sysv_file_mode
      $init_file_owner  = $irqbalance::sysv_file_owner
      $init_file_path   = "/etc/init.d/${irqbalance::service_name}"
      $init_file_source = $irqbalance::sysv_init_src

      ensure_resource('package', $irqbalance::sysv_package, {'ensure' => 'present' })
      Package[$irqbalance::sysv_package] -> Service['irqbalance']
    }
    'openrc': {
      $init_file_group  = $irqbalance::sysv_file_group
      $init_file_mode   = $irqbalance::sysv_file_mode
      $init_file_owner  = $irqbalance::sysv_file_owner
      $init_file_path   = "/etc/init.d/${irqbalance::service_name}"
      $init_file_source = $irqbalance::sysv_init_src

      ensure_resource('package', 'sys-apps/openrc', {'ensure' => 'present' })
      Package['sys-apps/openrc'] -> Service['irqbalance']
    }
    'redhat': {
      $init_file_group  = $irqbalance::sysv_file_group
      $init_file_mode   = $irqbalance::sysv_file_mode
      $init_file_owner  = $irqbalance::sysv_file_owner
      $init_file_path   = "/etc/init.d/${irqbalance::service_name}"
      $init_file_source = $irqbalance::sysv_init_src
    }
    'systemd': {
      $init_file_group  = $irqbalance::systemd_file_group
      $init_file_mode   = $irqbalance::systemd_file_mode
      $init_file_owner  = $irqbalance::systemd_file_owner
      $init_file_path   = "${irqbalance::systemd_service_dir}/${irqbalance::service_name}.service"
      $init_file_source = $irqbalance::systemd_init_src

      ensure_resource('package', $irqbalance::systemd_package, {'ensure' => 'present' })
      Package[$irqbalance::systemd_package] -> Service['irqbalance']

      file { $irqbalance::systemd_service_dir:
        ensure  => 'directory',
        group   => 'root',
        mode    => '2755',
        require => Package[$irqbalance::systemd_package]
      }
    }
    'upstart': {
      $init_file_group  = $irqbalance::upstart_file_group
      $init_file_mode   = $irqbalance::upstart_file_mode
      $init_file_owner  = $irqbalance::upstart_file_owner
      $init_file_path   = "/etc/init/${irqbalance::service_name}"
      $init_file_source = $irqbalance::upstart_init_src

      ensure_resource('package', $irqbalance::upstart_package, {'ensure' => 'present' })
      Package[$irqbalance::upstart_package] -> Service['irqbalance']
    }
    default: {
      fail('An unknown Puppet service_provider parameter was provided')
    }
  }

  if !($irqbalance::prefer_default_init_script) {

    file { $init_file_path:
      ensure  => file,
      content => $init_file_source,
      group   => $init_file_group,
      mode    => $init_file_mode,
      owner   => $init_file_owner,
    }

  }
}