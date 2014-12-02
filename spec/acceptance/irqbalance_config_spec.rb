require 'spec_helper_acceptance'

case fact('osfamily')
when 'Debian'
  config = '/etc/default/irqbalance'
when 'RedHat'
  config = '/etc/sysconfig/irqbalance'
when 'Suse'
  config = '/etc/sysconfig/irqbalance'
when 'Gentoo'
  config = '/etc/conf.d/irqbalance'
end

describe 'irqbalance::config class' do
  it 'sets up irqbalance config' do
    apply_manifest(%{
      class { 'irqbalance': }
    }, :catch_failures => true)
  end

  describe file("#{config}") do
    it { should be_file }
    it { should be_mode '644' }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end
