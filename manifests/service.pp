# == Class: irqbalance::service
#
# Class to manage the irqbalance service
#
class irqbalance::service inherits irqbalance {

  # On single processor systems or when oneshot is enabled irqbalance will
  # run and then terminate.
  # For these scenarios ignore service_ensure => 'running' as we don't want
  # Puppet to start irqbalance each Puppet run
  # Note that the irqbalance will still exit immediately on systems with a
  # shared cache and this module does not prevent this.

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
      notice("${module_name}: Single processor or oneshot parameter detected - service_ensure will be ignored.")
    }

    service { 'irqbalance':
      ensure   => $real_service_ensure,
      enable   => $irqbalance::service_enable,
      name     => $irqbalance::service_name,
      provider => $irqbalance::service_provider,
    }

  }

}

