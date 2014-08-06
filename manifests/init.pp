# == Class: irqbalance
#
# This module installs and manages the irqbalance daemon. It will accept any
# option or environment variable that irqbalance supports and will simply
# ignore anything not supported by the default irqbalance version that comes
# with the distribution.
#
# === Usage
#
# include '::irqbalance'
#
# See the README.md for the full list of parameters
#
class irqbalance (
  $affinity_mask              = $irqbalance::params::affinity_mask,
  $args_regex                 = $irqbalance::params::args_regex,
  $args                       = $irqbalance::params::args,
  $banirq                     = $irqbalance::params::banirq,
  $banned_cpus                = $irqbalance::params::banned_cpus,
  $banned_interrupts          = $irqbalance::params::banned_interrupts,
  $banscript                  = $irqbalance::params::banscript,
  $config                     = $irqbalance::params::config,
  $config_file_group          = $irqbalance::params::config_file_group,
  $config_file_mode           = $irqbalance::params::config_file_mode,
  $config_file_owner          = $irqbalance::params::config_file_owner,
  $config_file_source         = $irqbalance::params::config_file_source,
  $config_template            = $irqbalance::params::config_template,
  $deepestcache               = $irqbalance::params::deepestcache,
  $debug                      = $irqbalance::params::debug,
  $hintpolicy                 = $irqbalance::params::hintpolicy,
  $oneshot                    = $irqbalance::params::oneshot,
  $package_ensure             = $irqbalance::params::package_ensure,
  $package_name               = $irqbalance::params::package_name,
  $pid                        = $irqbalance::params::pid,
  $policyscript               = $irqbalance::params::policyscript,
  $powerthresh                = $irqbalance::params::powerthresh,
  $prefer_default_init_script = $irqbalance::params::prefer_default_init_script,
  $service_enable             = $irqbalance::params::service_enable,
  $service_ensure             = $irqbalance::params::service_ensure,
  $service_manage             = $irqbalance::params::service_manage,
  $service_name               = $irqbalance::params::service_name,
  $svc_provider               = $irqbalance::params::service_provider,
  $systemd_file_group         = $irqbalance::params::systemd_file_group,
  $systemd_file_mode          = $irqbalance::params::systemd_file_mode,
  $systemd_file_owner         = $irqbalance::params::systemd_file_owner,
  $systemd_init_source        = $irqbalance::params::systemd_init_source,
  $systemd_init_template      = $irqbalance::params::systemd_init_template,
  $systemd_service_dir        = $irqbalance::params::systemd_service_dir,
  $sysv_file_group            = $irqbalance::params::sysv_file_group,
  $sysv_file_mode             = $irqbalance::params::sysv_file_mode,
  $sysv_file_owner            = $irqbalance::params::sysv_file_owner,
  $sysv_init_source           = $irqbalance::params::sysv_init_source,
  $sysv_init_template         = $irqbalance::params::sysv_init_template,
  $upstart_file_group         = $irqbalance::params::upstart_file_group,
  $upstart_file_mode          = $irqbalance::params::upstart_file_mode,
  $upstart_file_owner         = $irqbalance::params::upstart_file_owner,
  $upstart_init_source        = $irqbalance::params::upstart_init_source,
  $upstart_init_template      = $irqbalance::params::upstart_init_template,
  $use_systemd_on_debian      = $irqbalance::params::use_systemd_on_debian,
  $use_upstart_on_debian      = $irqbalance::params::use_upstart_on_debian,
  $use_upstart_on_rhel6       = $irqbalance::params::use_upstart_on_rhel6,
) inherits irqbalance::params {

  # Non-default Init logic

  # Use Upstart on RHEL6 was selected
  if ($use_upstart_on_rhel6 and $::osfamily == 'RedHat' and $::operatingsystemrelease =~ /^6\.(\d+)/) {

    $service_provider = 'upstart'

    if !($args_regex) {
      $arguments_regex = '^(--banirq=.+|--banscript=.+|--debug|--hintpolicy=.+|--powerthresh=.+)$'
    }

    if !($upstart_init_template) {
      $init_template = 'irqbalance/init/upstart/el6-irqbalance.conf.erb'
    }

  }

  # Use Upstart on Debian 6 was selected
  if (($use_upstart_on_debian or $use_upstart_on_debian6) and $::osfamily == Debian and $::operatingsystemrelease =~ /^6\.(\d+)/) {

    $service_provider = 'upstart'

    if !($args_regex) {
      $arguments_regex = ''
    }

    if !($upstart_init_template) {
      $init_template = 'irqbalance/init/upstart/debian-noargs-irqbalance.conf.erb'
    }

  }

  # Use systemd on Debian 7 was selected
  if ($use_systemd_on_debian and $::osfamily == Debian and $::operatingsystemrelease =~ /^7\.(\d+)/) {

    $service_provider = 'systemd'

    if !(args_regex) {
      $arguments_regex = '^(--hintpolicy=.+|--powerthresh=.+)$'
    }

    if !($systemd_init_template) {
      $init_template = 'irqbalance/init/systemd/without-foreground-irqbalance.service.erb'
    }
  }

  # Use Upstart on Debian 7 selected
  elsif (($use_upstart_on_debian or $use_upstart_on_debian7) and $::osfamily == Debian and $::operatingsystemrelease =~ /^7\.(\d+)/) {

    $service_provider = 'upstart'

    if !(args_regex) {
      $arguments_regex = '^(--hintpolicy=.+|--powerthresh=.+)$'
    }

    if !($upstart_init_template) {
      $init_template = 'irqbalance/init/upstart/debian-without-foreground-irqbalance.conf.erb'
    }
  }

  else {

    $arguments_regex = $args_regex
    $service_provider = $svc_provider

    $init_template = $svc_provider ? {
      'debian'  => $sysv_init_template,
      'openrc'  => $sysv_init_template,
      'redhat'  => $sysv_init_template,
      'systemd' => $systemd_init_template,
      'upstart' => $upstart_init_template,
      default   => $sysv_init_template,
    }

  }

  case $service_provider {
    'debian': {
      $init_file_group  = $sysv_file_group
      $init_file_mode   = $sysv_file_mode
      $init_file_owner  = $sysv_file_owner
      $init_file_path   = "/etc/init.d/${irqbalance::service_name}"
      $init_file_source = $sysv_init_source
    }
    'openrc': {
      $init_file_group  = $sysv_file_group
      $init_file_mode   = $sysv_file_mode
      $init_file_owner  = $sysv_file_owner
      $init_file_path   = "/etc/init.d/${irqbalance::service_name}"
      $init_file_source = $sysv_init_source
    }
    'redhat': {
      $init_file_group  = $sysv_file_group
      $init_file_mode   = $sysv_file_mode
      $init_file_owner  = $sysv_file_owner
      $init_file_path   = "/etc/init.d/${irqbalance::service_name}"
      $init_file_source = $sysv_init_source
    }
    'systemd': {
      $init_file_group  = $systemd_file_group
      $init_file_mode   = $systemd_file_mode
      $init_file_owner  = $systemd_file_owner
      $init_file_path   = "${irqbalance::systemd_service_dir}/${irqbalance::service_name}.service"
      $init_file_source = $systemd_init_source

      file { $systemd_service_dir:
        ensure  => 'directory',
        group   => 'root',
        mode    => '2755',
      }

    }
    'upstart': {
      $init_file_group  = $upstart_file_group
      $init_file_mode   = $upstart_file_mode
      $init_file_owner  = $upstart_file_owner
      $init_file_path   = "/etc/init/${irqbalance::service_name}"
      $init_file_source = $upstart_init_source
    }
    default: {
      fail('An unknown Puppet service_provider parameter was provided')
    }
  }

  validate_absolute_path($config)
  validate_re($config_file_mode, '[0-7]{3,4}', 'An invalid config file mode value was provided.')
  validate_string($config_file_owner)
  validate_re($init_file_mode, '[0-7]{3,4}', 'An invalid init file mode value was provided.')
  validate_absolute_path($init_file_path)

  if ($init_file_source) {
    validate_string($init_file_source)
  }

  if ($init_template) {
    validate_string($init_template)
  }

  validate_string($package_ensure)
  validate_array($package_name)
  validate_bool($prefer_default_init_script)
  validate_bool($service_enable)
  validate_re($service_ensure, '^(running|stopped|true|false)$', 'The service_ensure value was invalid.')
  validate_bool($service_manage)
  validate_string($service_name)
  validate_string($service_provider)

  if !($config_file_source) {

    # Validate the environment variables for the configuration file if using a template

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

    # If a full set of options have been provided, each option will not be validated

    if ($args) {
      validate_string($args)
      $arguments = $args
    }

    else {

      # Check each irqbalance option that has been provided

      if ($banirq) {
        validate_array($banirq)
        # The banirq irqbalance option is additive only
        $banirq_withopt = prefix($banirq, '--banirq=')
        $banirq_args = join($banirq_withopt, ' ')
        validate_re($banirq_args, '^(--banirq=\d{2}(\s--banirq=\d{2})*)$', 'One or more invalid banirq values were provided.')
        # Used for a value check below
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
        true    => '--debug',
        default => undef,
      }

      # Join all the option-related parameters into an array and check if it is empty
      $arg_array = [
        $banirq_string,
        $banscript,
        $debug_string,
        $deepestcache,
        $hintpolicy,
        $pid,
        $policyscript,
        $powerthresh,
      ]
      $arg_values = join($arg_array)

      if (empty($arg_values)) {
        # Do nothing
      }

      else {
        # Join options together only if the irqbalance version on this
        # operating system accepts them
        $arg_commands = [
          $banirq_args,
          "--banscript=${banscript}",
          $debug_string,
          "--deepestcache=${deepestcache}",
          "--hintpolicy=${hintpolicy}",
          "--pid=${pid}",
          "--policyscript=${policyscript}",
          "--powerthresh=${powerthresh}",
          ]
        $acceptable_args = grep($arg_commands, $arguments_regex)

        if !(empty($acceptable_args)) {
          $arguments = join($acceptable_args, ' ')
        }
      }
    }
  }

  anchor { 'irqbalance::begin': } ->
  class { '::irqbalance::install': } ->
  class { '::irqbalance::config': } ~>
  class { '::irqbalance::service': } ->
  anchor { 'irqbalance::end': }

}