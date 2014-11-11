# irqbalance

[![Build Status](https://secure.travis-ci.org/juniorsysadmin/puppet-irqbalance.png)](http://travis-ci.org/juniorsysadmin/puppet-irqbalance)

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

#### Unmanaged service states

This module will not manage the running state of the irqbalance service when
applied to a single processor system, or when `oneshot` is set to yes. In
these scenarios the `service_ensure` parameter is simply ignored.

#### Init scripts

The Upstart init script that was included with Ubuntu Trusty Tahr (14.04)
does not seem to support the full set of options that the installed irqbalance
version itself supports.

If `manage_init_script_file` is set to true, this module will generally
provide a sensible init script replacement for Ubuntu distributions.
Additionally, if you wish to provide your own init script you can do so by
passing the appropriate parameter:
eg. `upstart_init_script_file_source` or `systemd_init_script_file_template`.

This module will default to using the following init types to manage the
service:

- CentOS/RHEL5 will use SysV init scripts.
- CentOS/RHEL6 will use SysV init scripts.
- CentOS/RHEL7 will use systemd.
- Fedora will use systemd.
- Debian 6 will use SysV init scripts.
- Debian 7 will use SysV init scripts.
- Ubuntu 10.04 will use Upstart.
- Ubuntu 12.04 will use Upstart.
- Ubuntu 14.04 will use Upstart.
- SLES 11 SP1 will use SysV init scripts.
- Gentoo will use OpenRC.

Debian 7 and Ubuntu 14.04 support systemd as a non-default init but note that
neither come with an irqbalance service unit file. Examples of managing
irqbalance under systemd on Debian/Ubuntu are shown below.

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
(These won't be checked to see if the installed irqbalance version supports
them)

```puppet
class { '::irqbalance':
  args => '--powerthresh=2 --deepestcache=2',
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

Manage irqbalance on Debian 7 under systemd (untested):

```puppet
class { '::irqbalance':
  $manage_init_script_file => true,
  $service_provider = 'systemd'
  $systemd_init_script_file_template = 'irqbalance/init/systemd/without-foreground-irqbalance.service.erb'
}
```

Manage irqbalance on Ubuntu 14.04 under systemd (untested):

```puppet
class { '::irqbalance':
  $manage_init_script_file => true,
  $service_provider = 'systemd'
  $systemd_init_script_file_template = 'irqbalance/init/systemd/with-foreground-irqbalance.service.erb'
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
eg. banned_interrupts => ['01', '03'],

#### `oneshot`

Can be set to 'yes', but accepts most boolean forms as a string. If set, the
`service_ensure` parameter will be ignored.
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
it from the command line.
eg. args => '--powerthresh=2 --deepestcache=2',

#### `config_file_group`

Group for the irqbalance configuration file. Defaults to '0'.

#### `config_file_mode`

Mode for the irqbalance configuration file. Defaults to '0644'.

#### `config_file_name`

The filename that the irqbalance configuration is written into.

#### `config_file_owner`

Owner for the irqbalance configuration file. Defaults to '0'.

#### `config_file_source`

Used for providing your own irqbalance configuration file.
Needs to follow the same requirements as the Puppet File source attribute.
eg. config_file_source => 'puppet:///modules/irqbalance/config/irq.conf',

#### `config_file_template`

Determines which template Puppet should use for the irqbalance configuration.

#### `dependency_class`

Determines whether to include a dependency class for this irqbalance module.
eg. dependency_class => 'irqbalance_deps',

#### `manage_init_script_file`

Determines whether to manage init scripts. Defaults to false. It is
recommended that this be set to true to ensure that you can use most
available options that irqbalance supports. This will also need to be set to
true if the distribution does not provide one for systemd. For example,
Debian Wheezy.

#### `package_ensure`

Sets the irqbalance package to be installed. Can be set to `present`,
'latest', or a specific version.

#### `package_manage`

Determines whether to manage the irqbalance package. Defaults to true.

#### `prefer_systemd`

Determines whether to use systemd init scripts on certain Debian or Ubuntu
distributions.

#### `service_enable`

Determines if the service should be enabled at boot.

#### `service_ensure`

Determines if the service should be running or not. This parameter is ignored
if running on a single processor system, or if `oneshot` is set to 'yes'.

#### `service_manage`

Selects whether Puppet should manage the service.
eg. service_manage => false

#### `systemd_init_script_file_group`

Group for the systemd init service file. Defaults to '0'.

#### `systemd_init_script_file_mode`

Mode for the systemd init service file. Defaults to '0644'.

#### `systemd_init_script_file_owner`

Owner for the systemd init service file. Defaults to '0'.

#### `systemd_init_script_file_source`

Used for providing your own irqbalance systemd service file for systems using
systemd.

#### `systemd_init_script_file_template`

Determines which systemd service template Puppet should use for systems using
systemd.

#### `sysv_init_script_file_group`

Group for SysV-like init scripts. Defaults to '0'.

#### `sysv_init_script_file_mode`

Mode for SysV-like init scripts. Defaults to '0755'.

#### `sysv_init_script_file_owner`

Owner for SysV-like init scripts. Defaults to '0'.

#### `sysv_init_script_file_source`

Used for providing your own irqbalance init script for systems using SysV-like
init.

#### `sysv_init_script_file_template`

Determines which init script template Puppet should use for systems using
SysV-like init.

#### `upstart_file_group`

Group for Upstart init scripts. Defaults to '0'.

#### `upstart_init_script_file_mode`

Mode for Upstart init scripts. Defaults to '0644'.

#### `upstart_init_script_file_owner`

Owner for Upstart init scripts. Defaults to '0'.

#### `upstart_init_script_file_source`

Used for providing your own irqbalance init script for systems using Upstart.

#### `upstart_init_script_file_template`

Determines which init script template Puppet should use for systems using
Upstart.

## Limitations

This module has received very limited testing on:

* CentOS/RHEL 5/6/7
* Debian 6/7
* Fedora 20
* SLES 11 SP1
* Ubuntu 10.04/12.04/14.04

against Puppet 2.7.x and 3.x

## Development

Patches are welcome.
