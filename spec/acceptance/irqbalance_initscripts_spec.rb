require 'spec_helper_acceptance'

case fact('osfamily')
when 'Debian'
  if (fact('operatingsystemrelease') =~ /^6\.(\d+)/ or fact('operatingsystemrelease') =~ /^7\.(\d+)/)
    initscript = '/etc/init.d/irqbalance'
  else
    initscript = '/etc/init/irqbalance.conf'
  end
when 'RedHat'
  if (fact('operatingsystemrelease') =~ /^5\.(\d+)/ or fact('operatingsystemrelease') =~ /^6\.(\d+)/)
    initscript = '/etc/init.d/irqbalance'
  else
    initscript = '/usr/lib/systemd/system/irqbalance.service'
  end
when 'Suse'
  initscript = '/etc/init.d/irqbalance'
when 'Gentoo'
  initscript = '/etc/init.d/irqbalance'
end

case initscript
when '/etc/init.d/irqbalance'
  group = 'root'
  mode  = '755'
  owner = 'root'
when '/etc/init/irqbalance.conf'
  group = 'root'
  mode  = '644'
  owner = 'root'
when '/usr/lib/systemd/system/irqbalance.service'
  group = 'root'
  mode  = '644'
  owner = 'root'
end

describe 'irqbalance::initscripts class' do
  it 'manages irqbalance init scripts' do
    apply_manifest(%{
      class { 'irqbalance': manage_init_script_file => true }
    }, :catch_failures => true)
  end

  describe file("#{initscript}") do
    it { should be_file }
    it { should be_mode "#{mode}" }
    it { should be_owned_by "#{owner}" }
    it { should be_grouped_into "#{group}" }
  end
end
