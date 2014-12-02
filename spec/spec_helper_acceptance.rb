require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'pry'

foss_opts = { :default_action => 'gem_install' }

hosts.each do |host|
  install_puppet ( foss_opts )
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|
      on host, "/bin/echo '' > #{host['hieraconf']}"
      on host, "mkdir -p #{host['distmoduledir']}"
      copy_module_to(host, :source => proj_root, :module_name => 'irqbalance')
      on host, "/bin/touch #{default['puppetpath']}/hiera.yaml"
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
