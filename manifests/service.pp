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

  if ($irqbalance::oneshot == 'yes' or $::processorcount == '1') {
    $real_service_ensure = 'stopped'
  }

  else {
    $real_service_ensure = $irqbalance::service_ensure
  }

  if ($irqbalance::service_manage) {

    service { 'irqbalance':
      ensure   => $real_service_ensure,
      enable   => $irqbalance::service_enable,
      name     => $irqbalance::service_name,
      provider => $irqbalance::service_provider,
    }

  }

}
