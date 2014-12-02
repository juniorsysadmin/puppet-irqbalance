require 'spec_helper_acceptance'

describe 'irqbalance class' do
  package_name = 'irqbalance'

  it 'should run successfully' do
    pp = "class { 'irqbalance': }"
    
    apply_manifest(pp, :catch_failures => true) do |r|
      expect(r.stderr).not_to match(/error/i)
    end
    apply_manifest(pp, :catch_failures => true) do |r|
      expect(r.stderr).not_to eq(/error/i)
      expect(r.exit_code).to be_zero
    end
  end

end

