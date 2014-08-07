# == Class: irqbalance::install
#
class irqbalance::install inherits irqbalance {

  package { 'irqbalance':
    ensure => $irqbalance::package_ensure,
    name   => $irqbalance::package_name,
  }

}