require 'spec_helper'

describe Turnout::Configuration do
  its(:app_root) { should be_a Pathname }
  its('app_root.to_s') { should eql '.' }

  it { expect { subject.app_root = '/tmp' }.to change { subject.app_root }.from(Pathname.new('.')).to Pathname.new('/tmp') }

  describe '#update' do
    context 'invalid settings' do
      let(:settings) { {bogus: 'blah'} }
      it { expect { subject.update(settings) }.to raise_exception ArgumentError }
    end

    context 'valid settings' do
      let(:settings) { {app_root: '/tmp'} }
      it { expect { subject.update(settings) }.to change { subject.app_root.to_s}.from('.').to '/tmp' }
    end
  end
end