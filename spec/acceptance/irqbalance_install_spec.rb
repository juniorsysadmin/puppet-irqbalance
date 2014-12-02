require 'spec_helper_acceptance'

describe 'irqbalance::install class' do
  it 'installs the package' do
    apply_manifest(%{
      class { 'irqbalance': }
    }, :catch_failures => true)
  end

  describe package('irqbalance') do
      it { should be_installed }
  end
end
