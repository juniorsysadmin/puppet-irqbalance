class irqbalance::install inherits irqbalance {

  if $irqbalance::package_manage {

    package { $irqbalance::package_name:
      ensure => $irqbalance::package_ensure,
    }

  }

}
