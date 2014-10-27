# == Class: irqbalance::params
#
# Default parameter values for the irqbalance module
#
class irqbalance::params {
  $affinity_mask                     = undef
  $args                              = undef
  $banirq                            = undef
  $banned_cpus                       = undef
  $banned_interrupts                 = undef
  $banscript                         = undef
  $config_file_group                 = '0'
  $config_file_mode                  = '0644'
  $config_file_owner                 = '0'
  $debug                             = false
  $dependency_class                  = undef
  $deepestcache                      = undef
  $hintpolicy                        = undef
  $manage_init_script_file           = false
  $oneshot                           = 'no'
  $package_ensure                    = 'present'
  $package_manage                    = true
  $pid                               = undef
  $policyscript                      = undef
  $powerthresh                       = undef
  $service_enable                    = true
  $service_ensure                    = 'running'
  $service_manage                    = true
  $systemd_init_script_file_group    = '0'
  $systemd_init_script_file_mode     = '0644'
  $systemd_init_script_file_owner    = '0'
  $systemd_init_script_file_source   = undef
  $systemd_init_script_file_template = undef
  $sysv_init_script_file_group       = '0'
  $sysv_init_script_file_mode        = '0755'
  $sysv_init_script_file_owner       = '0'
  $sysv_init_script_file_source      = undef
  $sysv_init_script_file_template    = undef
  $upstart_init_script_file_group    = '0'
  $upstart_init_script_file_mode     = '0644'
  $upstart_init_script_file_owner    = '0'
  $upstart_init_script_file_source   = undef

  case $::osfamily {
    'Debian': {
      $config_dir_path  = '/etc/default'
      $config_file_name = 'irqbalance'
      $irqbalance_path  = '/usr/sbin/irqbalance'
      $package_name     = [ 'irqbalance' ]
      $service_name     = 'irqbalance'
      $systemd_dir_path = '/lib/systemd/system'

      # Debian Squeeze
      # The irqbalance version included with Debian Squeeze is 0.56
      # The options accepted by this module are: none
      # The environment variables accepted by this module are:
      # IRQBALANCE_BANNED_CPUS= IRQBALANCE_BANNED_INTERRUPTS= ONESHOT=
      # The environment variables ignored by this module are:
      # IRQBALANCE_DEBUG IRQBALANCE_ONESHOT
      # The options ignored by this module are: --debug --oneshot

      if $::operatingsystemrelease =~ /^6\.(\d+)/ {
        $args_regex = '.^'
        $config_file_template = 'irqbalance/config/debian-irqbalance.erb'
        $service_provider = 'debian'
      }

      # Debian Wheezy
      # The irqbalance version included with Debian Wheezy is 1.03
      # This distribution's included SysV init script accepts options
      # The --foreground option was introduced after this version so
      # using --debug will not exit nicely regardless of the init used
      # This distribution's package does not come with a systemd service file
      # The options accepted by this module are: --hintpolicy=, --oneshot
      # --powerthresh=
      # The environment variables accepted by this module are:
      # IRQBALANCE_BANNED_CPUS= IRQBALANCE_BANNED_INTERRUPTS= ONESHOT=
      # OPTIONS=
      # The environment variables ignored by this module are:
      # IRQBALANCE_DEBUG IRQBALANCE_ONESHOT
      # The options ignored by this module are: --debug

      elsif $::operatingsystemrelease =~ /^7\.(\d+)/ {
        $args_regex= '^(--hintpolicy=(exact|subset|ignore)|--powerthresh=[\d]+)$'
        $config_file_template = 'irqbalance/config/debian-irqbalance.erb'
        $service_provider = 'debian'
      }

      # Ubuntu Lucid 10.04 LTS
      # The irqbalance version included with Ubuntu Lucid is 0.55
      # The environment variables accepted by this module are:
      # IRQBALANCE_BANNED_CPUS= IRQBALANCE_BANNED_INTERRUPTS= ONESHOT=
      # The environment variables ignored by this module are:
      # IRQBALANCE_DEBUG IRQBALANCE_ONESHOT
      # The options ignored by this module are: --debug --oneshot

      elsif $::operatingsystemrelease =~ /^10.04$/ {
        $args_regex = '.^'
        $config_file_template = 'irqbalance/config/debian-irqbalance.erb'
        $service_provider = 'upstart'
        $upstart_init_script_file_template = 'irqbalance/init/upstart/debian-noargs-irqbalance.conf.erb'
      }

      # Ubuntu Precise 12.04 LTS
      # The irqbalance version included with Ubuntu Precise is 0.56
      # The environment variables accepted by this module are:
      # IRQBALANCE_BANNED_CPUS= IRQBALANCE_BANNED_INTERRUPTS= ONESHOT=
      # The environment variables ignored by this module are:
      # IRQBALANCE_DEBUG IRQBALANCE_ONESHOT
      # The options ignored by this module are: --debug --oneshot

      elsif $::operatingsystemrelease =~ /^12.04$/ {
        $args_regex = '.^'
        $config_file_template = 'irqbalance/config/debian-irqbalance.erb'
        $service_provider = 'upstart'
        $upstart_init_script_file_template = 'irqbalance/init/upstart/debian-noargs-irqbalance.conf.erb'
      }

      # Ubuntu Trusty 14.04
      # The irqbalance version included with Ubuntu Trusty is 1.06
      # The options accepted by this module are: --banirq=, --debug
      # --hintpolicy=, --pid=, --policyscript=, --powerthresh=,
      # The environment variables accepted by this module are:
      # IRQBALANCE_BANNED_CPUS= ONESHOT=
      # The environment variables ignored by this module are:
      # IRQBALANCE_DEBUG IRQBALANCE_ONESHOT

      elsif $::operatingsystemrelease =~ /^14.04$/ {
        $args_regex = '^(--banirq=\d{2}(\s--banirq=\d{2})*|--debug|--hintpolicy=(exact|subset|ignore)|--pid=/.|--policyscript=/.|--powerthresh=[\d]+)$'
        $config_file_template = 'irqbalance/config/debian-10x-irqbalance.erb'
        $service_provider = 'upstart'
        $upstart_init_script_file_template = 'irqbalance/init/upstart/debian-with-foreground-irqbalance.conf.erb'
      }

      else {
          fail("The ${module_name} module is not supported on ${::operatingsystem} ${::operatingsystemrelease}.")
      }
    }

    'RedHat': {
      $config_dir_path  = '/etc/sysconfig'
      $config_file_name = 'irqbalance'
      $irqbalance_path  = '/usr/sbin/irqbalance'
      $package_name     = [ 'irqbalance' ]
      $service_name     = 'irqbalance'
      $systemd_dir_path = '/usr/lib/systemd/system'

      # CentOS/RHEL 5
      # The irqbalance version included with CentOS 5 is 0.55
      # The options accepted by this module are: none
      # The environment variables accepted by this module are:
      # IRQ_AFFINITY_MASK IRQBALANCE_BANNED_CPUS IRQBALANCE_BANNED_INTERRUPTS
      # ONESHOT
      # The environment variables ignored by this module are: IRQBALANCE_DEBUG
      # The options ignored by this module are: --debug --oneshot

      if $::operatingsystemrelease =~ /^5\.(\d+)/ {
        $args_regex = '.^'
        $config_file_template = 'irqbalance/config/el5-irqbalance.erb'
        $service_provider = 'redhat'
      }

      # CentOS/RHEL 6
      # The irqbalance version included with CentOS/RHEL 6 is 1.04
      # The options accepted by this module are: --banirq= --banscript --debug
      # --hintpolicy=, --powerthresh=
      # --debug is only accepted if Upstart is being used
      # The environment variables accepted by this module are:
      # IRQBALANCE_ARGS IRQBALANCE_BANNED_CPUS IRQBALANCE_ONESHOT
      # The environment variables ignored by this module are:
      # IRQBALANCE_DEBUG
      # The options ignored by this module are: --foreground --pid

      elsif $::operatingsystemrelease =~ /^6\.(\d+)/ {
        $args_regex = '^(--banirq=\d{2}(\s--banirq=\d{2})*|--banscript=/.|--hintpolicy=(exact|subset|ignore)|--powerthresh=[\d]+)$'
        $config_file_template = 'irqbalance/config/el6-irqbalance.erb'
        $service_provider = 'redhat'
      }
      
      # CentOS/RHEL 7
      # The irqbalance version included with CentOS/RHEL 7 is 1.06
      # The options accepted by this module are: --banirq=, --debug
      # --hintpolicy=, --pid=, --policyscript=, --powerthresh=,
      # The environment variables accepted by this module are:
      # IRQBALANCE_ARGS IRQBALANCE_BANNED_CPUS IRQBALANCE_ONESHOT
      # The environment variables ignored by this module are: IRQBALANCE_DEBUG
      # The options ignored by this module are: none

      elsif $::operatingsystemrelease =~ /^7\.(\d+)/ {
        $args_regex = '^(--banirq=\d{2}(\s--banirq=\d{2})*|--debug|--hintpolicy=(exact|subset|ignore)|--pid=/.|--policyscript=/.|--powerthresh=[\d]+)$'
        $config_file_template = 'irqbalance/config/el7-irqbalance.erb'
        $service_provider = 'systemd'
      }

      # Fedora
      # The irqbalance version included with Fedora 20 is 1.07
      # The options accepted by this module are: --banirq=, --debug
      # --deepestcache=, --hintpolicy=, --pid=, --policyscript=,
      # --powerthresh=,
      # The environment variables accepted by this module are:
      # IRQBALANCE_ARGS IRQBALANCE_BANNED_CPUS IRQBALANCE_ONESHOT
      # The environment variables ignored by this module are: IRQBALANCE_DEBUG
      # The options ignored by this module are: none

      elsif ($::operatingsystem == 'Fedora') and ($::operatingsystemrelease > '19') {
        $args_regex = '^(--banirq=\d{2}(\s--banirq=\d{2})*|--debug|--deepestcache=[1-9]\d*|--hintpolicy=(exact|subset|ignore)|--pid=/.|--policyscript=/.|--powerthresh=[\d]+)$'
        $config_file_template = 'irqbalance/config/fc-irqbalance.erb'
        $service_provider = 'systemd'
      }

      else {
        fail("The ${module_name} module is not supported on ${::operatingsystem} ${::operatingsystemrelease}.")
      }
    }

    'Suse': {
      $config_dir_path  = '/etc/sysconfig'
      $config_file_name = 'irqbalance'
      $irqbalance_path  = '/usr/sbin/irqbalance'
      $package_name     = [ 'irqbalance' ]
      $service_name     = 'irq_balancer'
      $systemd_dir_path = '/lib/systemd/system'

      # SLES 11
      # The irqbalance version included with SLES 11 is 0.55
      # The options accepted by this module are: none
      # The environment variables accepted by this module are:
      # IRQBALANCE_BANNED_CPUS IRQBALANCE_BANNED_INTERRUPTS ONESHOT
      # The environment variables ignored by this module are: IRQBALANCE_DEBUG
      # The options ignored by this module are: --debug --oneshot

      if ($::operatingsystem == 'SLES') and (versioncmp($::operatingsystemrelease, '10') > 0)  {
        $args_regex = '.^'
        $config_file_template = 'irqbalance/config/sles11-irqbalance.erb'
        $service_provider = 'redhat'
      }

      else {
        fail("The ${module_name} module is not supported on ${::operatingsystem} ${::operatingsystemrelease}.")
      }
    }

    # Gentoo was added as its own $::osfamily in Facter 1.7.0
    'Gentoo': {
      $config_dir       = '/etc/conf.d'
      $config_file_name = 'irqbalance'

      # Gentoo supports multiple irqbalance versions, which makes parsing
      # irqbalance environment variables or options too difficult.
      # Therefore providing a configuration file is mandatory

      $config_file_source = 'puppet:///modules/irqbalance/config/gentoo'
      $package_name       = [ 'irqbalance' ]
      $service_name       = 'irqbalance'
      $service_provider   = 'openrc'
    }

    'Linux': {
    # Before Facter 1.7.0 Gentoo did not have its own $::osfamily
      case $::operatingsystem {
        'Gentoo': {
          $config_dir       = '/etc/conf.d'
          $config_file_name = 'irqbalance'

          # Gentoo supports multiple irqbalance versions, which makes parsing
          # irqbalance environment variables or options too difficult.
          # Therefore providing a configuration file is mandatory

          $config_file_source = 'puppet:///modules/irqbalance/config/gentoo'
          $package_name       = [ 'irqbalance' ]
          $service_name       = 'irqbalance'
          $service_provider   = 'openrc'
        }
        default: {
          fail("The ${module_name} module is not supported on an ${::operatingsystem} distribution.")
        }
      }
    }

    default: {
      fail("The ${module_name} module is not supported on a ${::osfamily} based system.")
    }
  }
}
