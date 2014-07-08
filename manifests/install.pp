# == Class: irqbalance::install
#
# Module to install irqbalance.
#
class irqbalance::install inherits irqbalance {

  package { 'irqbalance':
    ensure => $irqbalance::package_ensure,
    name   => $irqbalance::package_name,
  }

  # If the package is installed, but we are using a non-default init, we need
  # to kill the irqbalance if the package manager starts it by default
  # (eg. Debian)
  exec { 'terminate-irqbalance-instances':
    command     => '/usr/bin/pkill irqbalance',
    refreshonly => true,
    subscribe   => Package['irqbalance'],
  }
}
