require 'spec_helper'

describe Turnout::Configuration do
  let(:config) { Turnout::Configuration.new }
  subject { config }

  describe '#app_root' do
    its(:app_root) { should be_a Pathname }
    its('app_root.to_s') { should eql '.' }
    it { expect { subject.app_root = '/tmp' }.to change { subject.app_root }.from(Pathname.new('.')).to Pathname.new('/tmp') }
  end

  describe '#named_maintenance_file_paths' do
    subject { config.named_maintenance_file_paths }

    it { should eq(default: 'tmp/maintenance.yml') }

    context 'when a string is given as a key' do
      before { config.named_maintenance_file_paths = {'new' => 'tmp/new.yml'} }

      it 'should convert the key to a symbol' do
        should have_key :new
      end
    end
  end

  describe '#default_maintenance_page' do
    its(:default_maintenance_page) { should eql Turnout::MaintenancePage::HTML }
  end

  describe '#default_reason' do
    its(:default_reason) { should eql "The site is temporarily down for maintenance.\nPlease check back soon." }
  end

  describe '#default_response_code' do
    its(:default_response_code) { should eql 503}
  end

  describe '#default_retry_after' do
    its(:default_retry_after) { should eql 7200 }
  end

  describe '#update' do
    context 'invalid settings' do
      let(:settings) { {bogus: 'blah'} }
      it { expect { subject.update(settings) }.to raise_exception ArgumentError }
    end

    context 'valid settings' do
      let(:settings) { {app_root: '/tmp'} }
      it { expect { subject.update(settings) }.to change { subject.app_root.to_s}.from('.').to '/tmp' }
    end

    context 'named_maintenance_file_paths' do
      let(:settings) { {named_maintenance_file_paths: {test: 'tmp/main_dir'}} }
      it { expect { subject.update(settings) }.to change { subject.named_maintenance_file_paths }.to(test: 'tmp/main_dir') }
    end
  end
end