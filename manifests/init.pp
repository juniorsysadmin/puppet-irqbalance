# == Class: irqbalance

class irqbalance (
  $affinity_mask           = $irqbalance::params::affinity_mask,
  $arg_regex               = $irqbalance::params::arg_regex,
  $args                    = $irqbalance::params::args,
  $banirq                  = $irqbalance::params::banirq,
  $banned_cpus             = $irqbalance::params::banned_cpus,
  $banned_interrupts       = $irqbalance::params::banned_interrupts,
  $banscript               = $irqbalance::params::banscript,
  $config                  = $irqbalance::params::config,
  $config_file_group       = $irqbalance::params::config_file_group,
  $config_file_mode        = $irqbalance::params::config_file_mode,
  $config_file_owner       = $irqbalance::params::config_file_owner,
  $config_template_source  = $irqbalance::params::config_template_source,
  $deepestcache            = $irqbalance::params::deepestcache,
  $debug                   = $irqbalance::params::debug,
  $full_args_provided      = $irqbalance::params::full_args_provided,
  $hintpolicy              = $irqbalance::params::hintpolicy,
  $oneshot                 = $irqbalance::params::oneshot,
  $package_ensure          = $irqbalance::params::package_ensure,
  $package_name            = $irqbalance::params::package_name,
  $pid                     = $irqbalance::params::pid,
  $policyscript            = $irqbalance::params::policyscript,
  $powerthresh             = $irqbalance::params::powerthresh,
  $service_enable          = $irqbalance::params::service_enable,
  $service_ensure          = $irqbalance::params::service_ensure,
  $service_manage          = $irqbalance::params::service_manage,
  $service_provider        = $irqbalance::params::service_provider,
  $service_name            = $irqbalance::params::service_name,
  $systemd_file_group      = $irqbalance::params::systemd_file_group,
  $systemd_file_mode       = $irqbalance::params::systemd_file_mode,
  $systemd_file_owner      = $irqbalance::params::systemd_file_owner,
  $systemd_init_source     = $irqbalance::params::systemd_init_source,
  $systemd_package         = $irqbalance::params::systemd_package,
  $systemd_service_dir     = $irqbalance::params::systemd_service_dir,
  $sysv_file_group         = $irqbalance::params::sysv_file_group,
  $sysv_file_mode          = $irqbalance::params::sysv_file_mode,
  $sysv_file_owner         = $irqbalance::params::sysv_file_owner,
  $sysv_init_source        = $irqbalance::params::sysv_init_source,
  $sysv_package            = $irqbalance::params::sysv_package,
  $upstart_file_group      = $irqbalance::params::upstart_file_group,
  $upstart_file_mode       = $irqbalance::params::upstart_file_mode,
  $upstart_file_owner      = $irqbalance::params::upstart_file_owner,
  $upstart_init_source     = $irqbalance::params::upstart_init_source,
  $upstart_package         = $irqbalance::params::upstart_package,
  $use_default_init_script = $irqbalance::params::use_default_init_script
) inherits irqbalance::params {

  validate_absolute_path($config)
  validate_string($config_file_group)
  validate_re($config_file_mode, '[0-7]{3}', 'An invalid config_file_mode value was provided.')
  validate_string($config_file_owner)

  if ($irqbalance::params::config_file_source) {
    $config_file_source = $irqbalance::params::config_file_source
    validate_string($config_file_source)
  }

  else {
    $config_file_source = 'template($irqbalance::config_template_source)'
  }

  validate_string($config_template_source)
  validate_string($package_ensure)
  validate_array($package_name)
  validate_bool($service_enable)
  validate_re($service_ensure, '^(running|stopped|true|false)$', 'The service_ensure value was invalid.')
  validate_bool($service_manage)
  validate_string($service_name)

  # Validate the variables for the configuration file

  if ($affinity_mask) {
    validate_array($affinity_mask)
    $affinity_mask_args = join($affinity_mask, ',')
    validate_re($affinity_mask_args, '^([0-9a-fA-F]+(,[0-9a-fA-F]+)*)$', 'An invalid affinity_mask value was provided.')
  }

  if ($banned_cpus) {
    validate_array($banned_cpus)
    $banned_cpus_args = join($banned_cpus, ',')
    validate_re($banned_cpus_args, '^([0-9a-fA-F]+(,[0-9a-fA-F]+)*)$', 'An invalid banned_cpu value was provided.')
  }

  if ($banned_interrupts) {
    validate_array($banned_interrupts)
    $banned_interrupts_args = join($banned_interrupts, ' ')
    validate_re($banned_interrupts_args, '^(\d{2}(\s\d{2})*)$', 'One or more invalid banned_interrupts values were provided.')
  }

  if ($oneshot) {
      validate_re($oneshot, '^yes$', 'If the oneshot value is given it must be set to yes.')
  }

  if ($full_args_provided) {
    # If a full set of arguments/options is given, each option is not validated
    validate_string($args)
    $arguments = $args
  }

  else {

    # Check each irqbalance argument/option

    if ($banirq) {
      validate_array($banirq)
      # The banirq irqbalance option is additive only
      $banirq_withopt = prefix($banirq, '--banirq=')
      $banirq_args = join($banirq_withopt, ' ')
      validate_re($banirq_args, '^(--banirq=\d{2}(\s--banirq=\d{2})*)$', 'One or more invalid banirq values were provided.')
      # Used for value check below
      $banirq_string = join($banirq)
    }

    if ($banscript) {
      validate_absolute_path($banscript)
    }

    if ($deepestcache) {
      validate_re($deepestcache, '[1-9]\d*', 'The deepestcache option value must be a positive integer.')
    }

    if ($debug) {
      validate_bool($debug)
    }

    if ($hintpolicy) {
      validate_re($hintpolicy, '^(exact|subset|ignore)$', 'The hintpolicy option value must be either exact, subset or ignore.')
    }

    if ($pid) {
      validate_absolute_path($pid)
    }

    if ($policyscript) {
      validate_absolute_path($policyscript)
    }

    if ($powerthresh) {
      validate_re($powerthresh, '[\d]+', 'The powerthresh option value must be an integer.')
    }

    $debug_string = $debug ? {
    true => '--debug',
    default => undef,
    }

    # Join all the option-related parameters into an array and check if it is empty
    $arg_array = [ $banirq_string, $banscript, $debug_string, $deepestcache, $hintpolicy, $pid, $policyscript, $powerthresh, ]
    $arg_values = join($arg_array)

    if (empty($arg_values)) {
      # Do nothing
    }

    else {
      # Join options together only if the irqbalance version on this
      # operating system accepts them
      $arg_commands = [$banirq_args, "--banscript=${banscript}", $debug_string, "--deepestcache=${deepestcache}", "--hintpolicy=${hintpolicy}", "--pid=${pid}", "--policyscript=${policyscript}", "--powerthresh=${powerthresh}", ]
      $acceptable_args = grep($arg_commands, $arg_regex)

      if !(empty($acceptable_args)) {
        $arguments = join($acceptable_args, ' ')
      }
    }

  }

  anchor { 'irqbalance::begin': } ->
  class { '::irqbalance::install': } ->
  class { '::irqbalance::config': } ~>
  class { '::irqbalance::service': } ->
  anchor { 'irqbalance::end': }

}