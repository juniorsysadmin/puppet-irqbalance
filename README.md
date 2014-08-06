# irqbalance

#### Table of Contents

1. [Overview](#overview)
2. [Usage](#usage)
3. [Limitations](#limitations)
4. [Development](#development)

## Overview

This module installs and manages the irqbalance daemon. It will accept any
option or environment variable that irqbalance supports and will simply ignore
anything not supported by the default irqbalance version that comes with the
distribution.

By default:
- CentOS/RHEL5 will use SysV init scripts.
- CentOS/RHEL6 will use SysV init scripts (but can use Upstart).
- Fedora will use systemd.
- Debian 6 will use SysV init scripts (but can use Upstart).
- Debian 7 will use SysV init scripts (but can use Upstart or systemd).
- Ubuntu 10.04 will use Upstart.
- Ubuntu 12.04 will use Upstart.
- Ubuntu 14.04 will use Upstart (but can use systemd).
- Gentoo will use OpenRC.

If using non-default init scripts, this module will assume that all of the
required Init packages are already installed:
- Redhat will require the systemd/upstart package.
- Debian will require the systemd-sysv/upstart package.
- Ubuntu will require the systemd-services package.

The Upstart init scripts that come with Ubuntu sadly do not support options,
so this module replaces them with Upstart init scripts which do. If you would
rather that it did not, use the `prefer_default_init_script` parameter.

[![Build
Status](https://secure.travis-ci.org/juniorsysadmin/puppet-irqbalance.png)](http://travis-ci.org/juniorsysadmin/puppet-irqbalance)

## Usage

Install and run the irqbalance service using the distribution defaults:

```puppet
include  '::irqbalance'
```

Set the powerthresh option to 2 if the irqbalance version included with this
distribution supports it:

```puppet
class { '::irqbalance':
  powerthresh => '2',
}
```

Set all of the irqbalance options at once:
(These won't be checked to see if this irqbalance version supports them all.)

```puppet
class { '::irqbalance':
  args => '--powerthresh=2 --deepestcache=2',
}
```

Use systemd when running on Debian 7 or Upstart when running on a RHEL6 system:

```puppet
class { '::irqbalance':
  use_systemd_on_debian => true,
  use_upstart_on_rhel6  => true,
}
```

Set the ONESHOT environment variable:

```puppet
class { '::irqbalance':
  oneshot => 'yes',
}
```

Use your own irqbalance configuration file:

```puppet
class { '::irqbalance':
  config_file_source => '/path/to/config',
}
```

### Parameters

#### Environment variables for the configuration file:

#### `affinity_mask`

Must be an array.
eg. affinity_mask => ['ff000000', '0000000'],

#### `banned_cpus`

Must be an array.
eg. banned_cpus => ['fc3', '0000001'],

#### `banned_interrupts`

Must be an array.
eg. banned_interrupts => ['33f', '3d'],

#### `oneshot`

If set, must be set to 'yes'. `service_ensure` will be forced to 'stopped' if
set.
eg. oneshot => 'yes',

#### Options passed to the service:

#### `banirq`

Must be an array.
eg. banirq => ['01', '03', '04'],

#### `banscript`

eg. banscript => '/path/to/banscript.sh',

#### `debug`

Must be set to true or false. Mostly ignored unless the irqbalance version
also supports the foreground option.
eg. debug => true,

#### `deepestcache`

eg. deepestcache => '2',

#### `hintpolicy`

eg. hintpolicy => 'exact',

#### `pid`

Generally ignored when using SysV init scripts, as they use their own path.

eg. pid => '/path/to/irqbalance.pid',

#### `policyscript`

eg. policyscript => '/path/to/policyscript.sh',

#### `powerthresh`

eg. powerthresh => '2',

#### Other parameters:

#### `args`

Options that will passed to irqbalance, in the same way that one would do
it from the command line. If this parameter is set all of the option parameters
above, if set, will be ignored.
eg. args => '--powerthresh=2 --deepestcache=2',

#### `config`

Sets the file that the irqbalance configuration is written into.
eg. config => '/etc/irqbalance.conf',

#### `config_file_source`

Used for providing your own irqbalance configuration file.
Needs to follow the same requirements as the Puppet File source attribute.
eg. config_file_source => 'puppet:///modules/irqbalance/config/irq.conf',

#### `config_file_group`

Group for the irqbalance configuration file. Defaults to '0'.

#### `config_file_mode`

Mode for the irqbalance configuration file. Defaults to '0644'.

#### `config_file_owner`

Owner for the irqbalance configuration file. Defaults to '0'.

#### `config_template`

Determines which template Puppet should use for the irqbalance configuration.

#### `package_ensure`

Sets the irqbalance package to be installed. Can be set to 'present',
'latest', or a specific version.

#### `package_name`

Determines the name of the package to install. Must be an array.
eg. package_name = [ 'irqbalance' ],

#### `prefer_default_init_script`

In certain cases, this module replaces the distribution-provided init scripts
with its own, so that irqbalance options don't get ignored. If you would prefer
that these be left alone, set this to 'true'. This also means that this module
won't create a relevant init file, even if the distribution does not provide
one. For example, on Debian Wheezy running systemd.

#### `service_enable`

Determines if the service should be enabled at boot.

#### `service_ensure`

Determines if the service should be running or not. This parameter is ignored
if running on a single processor system, or if `oneshot` = 'yes'.

#### `service_manage`

Selects whether Puppet should manage the service.
eg. service_manage => false

#### `service_name`

Selects the name of the irqbalance service for Puppet to manage.

#### `systemd_file_group`

Group for the systemd init service file. Defaults to '0'.

#### `systemd_file_mode`

Mode for the systemd init service file. Defaults to '0644'.

#### `systemd_file_owner`

Owner for the systemd init service file. Defaults to '0'.

#### `systemd_init_source`

Used for providing your own irqbalance systemd service file for systems using
systemd.

#### `systemd_init_template`

Determines which systemd service template Puppet should use for systems using
systemd.

#### `systemd_service_dir`

Determines the directory into which the systemd service file should be
installed.

#### `sysv_file_group`

Group for SysV-like init scripts. Defaults to '0'.

#### `sysv_file_mode`

Mode for SysV-like init scripts. Defaults to '0755'.

#### `sysv_file_owner`

Owner for SysV-like init scripts. Defaults to '0'.

#### `sysv_init_source`

Used for providing your own irqbalance init script for systems using SysV-like
Init.

#### `sysv_init_template`

Determines which init script template Puppet should use for systems using
SysV-like Init.

#### `upstart_file_group`

Group for Upstart init scripts. Defaults to '0'.

#### `upstart_file_mode`

Mode for Upstart init scripts. Defaults to '0644'.

#### `upstart_file_owner`

Owner for Upstart init scripts. Defaults to '0'.

#### `upstart_init_source`

Used for providing your own irqbalance init script for systems using Upstart.

#### `upstart_init_template`

Determines which init script template Puppet should use for systems using
Upstart.

## Limitations

This module has received limited testing on:

* CentOS/RHEL 5/6
* Debian 6/7
* Fedora 19/20
* Ubuntu 10.04/12.04/14.04

against Puppet 2.7 and 3.x

## Development

Patches are welcome.