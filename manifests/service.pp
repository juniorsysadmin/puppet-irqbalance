# == Class: irqbalance::service
#
# Class to manage the irqbalance service
#

class irqbalance::service inherits irqbalance {

  if ($irqbalance::service_manage == true) {

    service { 'irqbalance':
      ensure      => $irqbalance::service_ensure,
      enable      => $irqbalance::service_enable,
      name        => $irqbalance::service_name,
      provider    => $irqbalance::service_provider,
    }

  }

}
