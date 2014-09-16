# == Class: irqbalance::service
#
# Class to manage the irqbalance service
#
class irqbalance::service inherits irqbalance {

  # irqbalance runs, then terminates for these scenarios.
  # Ignore service_ensure => 'running' as we don't want Puppet to start
  # irqbalance each Puppet run
  # irqbalance will still exit almost immediately on shared cache systems
  # however.

  if $irqbalance::oneshot == 'yes' {
    $oneshot_set = true
  }

  if $::processorcount == '1' {
    $singleprocessor = true
  }

  $ignore_service_ensure = $irqbalance::bool_oneshot or $singleprocessor

  $real_service_ensure = $ignore_service_ensure ? {
    true    => undef,
    default => $irqbalance::service_ensure,
  }

  if $irqbalance::service_manage {

    if $ignore_service_ensure {
      notice("${module_name}: Single processor or \$oneshot parameter detected - \$service_ensure parameter will be ignored.")
    }

    service { 'irqbalance':
      ensure   => $real_service_ensure,
      enable   => $irqbalance::service_enable,
      name     => $irqbalance::service_name,
      provider => $irqbalance::service_provider,
    }

  }

}
