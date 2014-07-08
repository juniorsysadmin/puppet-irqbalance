require 'spec_helper'

describe 'irqbalance', :type => :class do
  let(:facts) {{ :osfamily => 'RedHat', :operatingsystem => 'Fedora', :operatingsystemrelease => '20' }}
  it { should compile.with_all_deps }
  it { should create_class('irqbalance') }
  it { should contain_class('irqbalance::params') }
end
