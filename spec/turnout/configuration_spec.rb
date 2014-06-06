require 'spec_helper'

describe Turnout::Configuration do
  its(:app_root) { should be_a Pathname }
  its('app_root.to_s') { should eql '.' }
  its(:dir) { should eq('tmp') }

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

    context 'maintenance dir' do
      let(:settings) { {dir: 'tmp/main_dir'} }
      it { expect { subject.update(settings) }.to change { subject.dir.to_s }.from('tmp').to 'tmp/main_dir' }
    end

  end
end