# == Class: irqbalance::install
#
class irqbalance::install inherits irqbalance {

  if $irqbalance::package_manage {

    package { 'irqbalance':
      ensure => $irqbalance::package_ensure,
      name   => $irqbalance::package_name,
    }
  
  }

}
