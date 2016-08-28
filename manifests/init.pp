class irqbalance (
  $affinity_mask                     = $irqbalance::params::affinity_mask,
  $args                              = $irqbalance::params::args,
  $args_regex                        = $irqbalance::params::args_regex,
  $banirq                            = $irqbalance::params::banirq,
  $banned_cpus                       = $irqbalance::params::banned_cpus,
  $banned_interrupts                 = $irqbalance::params::banned_interrupts,
  $banscript                         = $irqbalance::params::banscript,
  $config_dir_path                   = $irqbalance::params::config_dir_path,
  $config_file_group                 = $irqbalance::params::config_file_group,
  $config_file_mode                  = $irqbalance::params::config_file_mode,
  $config_file_name                  = $irqbalance::params::config_file_name,
  $config_file_owner                 = $irqbalance::params::config_file_owner,
  $config_file_source                = $irqbalance::params::config_file_source,
  $config_file_template              = $irqbalance::params::config_file_template,
  $deepestcache                      = $irqbalance::params::deepestcache,
  $debug                             = $irqbalance::params::debug,
  $dependency_class                  = $irqbalance::params::dependency_class,
  $hintpolicy                        = $irqbalance::params::hintpolicy,
  $irqbalance_path                   = $irqbalance::params::irqbalance_path,
  $manage_init_script_file           = $irqbalance::params::manage_init_script_file,
  $manage_systemd_dir_path           = $irqbalance::params::manage_systemd_dir_path,
  $oneshot                           = $irqbalance::params::oneshot,
  $package_ensure                    = $irqbalance::params::package_ensure,
  $package_manage                    = $irqbalance::params::package_manage,
  $package_name                      = $irqbalance::params::package_name,
  $pid                               = $irqbalance::params::pid,
  $policyscript                      = $irqbalance::params::policyscript,
  $powerthresh                       = $irqbalance::params::powerthresh,
  $service_enable                    = $irqbalance::params::service_enable,
  $service_ensure                    = $irqbalance::params::service_ensure,
  $service_manage                    = $irqbalance::params::service_manage,
  $service_name                      = $irqbalance::params::service_name,
  $service_provider                  = $irqbalance::params::service_provider,
  $systemd_dir_path                  = $irqbalance::params::systemd_dir_path,
  $systemd_init_script_file_group    = $irqbalance::params::systemd_init_script_file_group,
  $systemd_init_script_file_mode     = $irqbalance::params::systemd_init_script_file_mode,
  $systemd_init_script_file_owner    = $irqbalance::params::systemd_init_script_file_owner,
  $systemd_init_script_file_source   = $irqbalance::params::systemd_init_script_file_source,
  $systemd_init_script_file_template = $irqbalance::params::systemd_init_script_file_template,
  $sysv_init_script_file_group       = $irqbalance::params::sysv_init_script_file_group,
  $sysv_init_script_file_mode        = $irqbalance::params::sysv_init_script_file_mode,
  $sysv_init_script_file_owner       = $irqbalance::params::sysv_init_script_file_owner,
  $sysv_init_script_file_source      = $irqbalance::params::sysv_init_script_file_source,
  $sysv_init_script_file_template    = $irqbalance::params::sysv_init_script_file_template,
  $upstart_init_script_file_group    = $irqbalance::params::upstart_init_script_file_group,
  $upstart_init_script_file_mode     = $irqbalance::params::upstart_init_script_file_mode,
  $upstart_init_script_file_owner    = $irqbalance::params::upstart_init_script_file_owner,
  $upstart_init_script_file_source   = $irqbalance::params::upstart_init_script_file_source,
  $upstart_init_script_file_template = $irqbalance::params::upstart_init_script_file_template,
) inherits irqbalance::params {

  if $dependency_class {
    warning("${module_name}: dependency_class is deprecated and will be removed in the next release.")
    require $dependency_class
  }

  if (versioncmp($::rubyversion, '2.1.0') < 0) {
    warning("${module_name}: Ruby ${::rubyversion} will not be supported in the next release.")
  }

  if (versioncmp($::facterversion, '2.4.0') < 0) {
    warning("${module_name}: Facter: ${::facterversion} will not be supported in the next release.")
  }

  case $service_provider {
    /(debian|openrc|redhat)/: {
      $init_script_file_group    = $sysv_init_script_file_group
      $init_script_file_mode     = $sysv_init_script_file_mode
      $init_script_file_owner    = $sysv_init_script_file_owner
      $init_script_file_path     = "/etc/init.d/${irqbalance::service_name}"
      $init_script_file_source   = $sysv_init_script_file_source
      $init_script_file_template = $sysv_init_script_file_template
    }
    'systemd': {
      $init_script_file_group    = $systemd_init_script_file_group
      $init_script_file_mode     = $systemd_init_script_file_mode
      $init_script_file_owner    = $systemd_init_script_file_owner
      $init_script_file_path     = "${irqbalance::systemd_dir_path}/${irqbalance::service_name}.service"
      $init_script_file_source   = $systemd_init_script_file_source
      $init_script_file_template = $systemd_init_script_file_template

      if $manage_systemd_dir_path {
        warning("${module_name}: manage_systemd_dir_path will be removed in the next release.")
        file { $systemd_dir_path:
          ensure => 'directory',
          group  => '0',
          mode   => '2755',
        }
      }
    }
    'upstart': {
      $init_script_file_group    = $upstart_init_script_file_group
      $init_script_file_mode     = $upstart_init_script_file_mode
      $init_script_file_owner    = $upstart_init_script_file_owner
      $init_script_file_path     = "/etc/init/${irqbalance::service_name}.conf"
      $init_script_file_source   = $upstart_init_script_file_source
      $init_script_file_template = $upstart_init_script_file_template
    }
    default: {
      fail('An unknown Puppet service_provider parameter was provided')
    }
  }

  validate_absolute_path($config_dir_path)
  validate_re($config_file_mode, '[0-7]{3,4}', 'An invalid config file mode value was provided.')
  validate_string($config_file_owner)
  validate_re($init_script_file_mode, '[0-7]{3,4}', 'An invalid init file mode value was provided.')
  validate_absolute_path($init_script_file_path)

  if ($init_script_file_source) {
    validate_string($init_script_file_source)
  }

  if ($init_script_file_template) {
    validate_string($init_script_file_template)
  }

  validate_string($package_ensure)
  validate_bool($package_manage)
  validate_array($package_name)
  validate_bool($manage_init_script_file)
  validate_bool($service_enable)
  validate_re($service_ensure, '^(running|stopped|true|false)$', 'The service_ensure value was invalid.')
  validate_bool($service_manage)
  validate_string($service_name)
  validate_string($service_provider)

  $bool_oneshot = str2bool($oneshot)

  if !$config_file_source {

    # Validate the environment variables for the configuration file if using a template

    if $affinity_mask {
      validate_array($affinity_mask)
      $affinity_mask_args = join($affinity_mask, ',')
      validate_re($affinity_mask_args, '^([0-9a-fA-F]+(,[0-9a-fA-F]+)*)$', 'An invalid affinity_mask value was provided.')
    }

    if $banned_cpus {
      validate_array($banned_cpus)
      $banned_cpus_args = join($banned_cpus, ',')
      validate_re($banned_cpus_args, '^([0-9a-fA-F]+(,[0-9a-fA-F]+)*)$', 'An invalid banned_cpu value was provided.')
    }

    if $banned_interrupts {
      validate_array($banned_interrupts)
      $banned_interrupts_args = join($banned_interrupts, ' ')
      validate_re($banned_interrupts_args, '^(\d{2}(\s\d{2})*)$', 'One or more invalid banned_interrupts values were provided.')
    }

    # If a full set of options have been provided, each option will not be validated

    if $args {
      validate_string($args)
      $real_args = $args
    }

    else {

      # Check each irqbalance option that has been provided

      if $banirq {
        validate_array($banirq)
        # The banirq irqbalance option is additive only
        $banirq_withopt = prefix($banirq, '--banirq=')
        $banirq_args = join($banirq_withopt, ' ')
        validate_re($banirq_args, '^(--banirq=\d{2}(\s--banirq=\d{2})*)$', 'One or more invalid banirq values were provided.')
      }

      else {
        $banirq_args = ''
      }

      if $banscript {
        validate_absolute_path($banscript)
      }

      if $deepestcache {
        validate_re($deepestcache, '[1-9]\d*', 'The deepestcache option value must be a positive integer.')
      }

      if $debug {
        validate_bool($debug)
      }

      if $hintpolicy {
        validate_re($hintpolicy, '^(exact|subset|ignore)$', 'The hintpolicy option value must be either exact, subset or ignore.')
      }

      if $pid {
        validate_absolute_path($pid)
      }

      if $policyscript {
        validate_absolute_path($policyscript)
      }

      if $powerthresh {
        validate_re($powerthresh, '[\d]+', 'The powerthresh option value must be an integer.')
      }

      $real_debug_string = $debug ? {
        true    => '--debug',
        default => '',
      }

      # Join options together only if the irqbalance version on this
      # operating system accepts them
      $arg_commands = [
        $banirq_args,
        "--banscript=${banscript}",
        $real_debug_string,
        "--deepestcache=${deepestcache}",
        "--hintpolicy=${hintpolicy}",
        "--pid=${pid}",
        "--policyscript=${policyscript}",
        "--powerthresh=${powerthresh}",
        ]

      $acceptable_args = grep($arg_commands, $args_regex)

      if !empty($acceptable_args) {
        $real_args = join($acceptable_args, ' ')
      }

    }
  }

  anchor { 'irqbalance::begin':
    before => Class['::irqbalance::install'],
  }

  class { '::irqbalance::install':
    before => [
    Class['::irqbalance::config'],
    Class['::irqbalance::initscripts'],
    ],
  }

  class { '::irqbalance::config':
    notify => Class['::irqbalance::service'],
  }

  class { '::irqbalance::initscripts':
    notify => Class['::irqbalance::service'],
  }

  class { '::irqbalance::service': } ->
  anchor { 'irqbalance::end': }

}
