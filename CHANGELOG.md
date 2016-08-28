## Future

## Backwards-incompatible changes

none

### Summary

Code cleanup and preparation for next major release

### Features

- Drops testing and support of Puppet versions less than 3.8.7
- Drops testing of Facter versions less than 2.4.0
- Drops testing of Ruby versions less than 2.1.9
- Deprecates `dependency_class` parameter
- Removes comments and whitespace taken from vendor defaults in irqbalance config
  templates
- Adds explicit Puppet 4 support
- Bumps stdlib minimum required version to 4.6.0
- Uses '0' for group rather than 'root'

### Bugs

- Provides a workaround to #1 by with `manage_systemd_dir_path => false`

## 2015-01-11 Release 1.0.4

### Backwards-incompatible changes:

none

### Summary

Version bump

### Features:

- None

### Bugs:

- Fixed package resource to allow multiple packages
- Fixed parser errors when strict_variables is set

## 2014-12-02 Release 1.0.3

### Backwards-incompatible changes:

none

### Summary

Bug fix release

### Features:

- Added a full set of rspec unit tests and basic acceptance tests

### Bugs:

- Fixed typo that caused the args parameter to be ignored
- Fixed template typo that caused this module to fail on Ubuntu 14.04
- Fixed handling of banscript, pid and policyscript parameters
