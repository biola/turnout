require 'spec_helper'

describe Turnout::MaintenanceFile do
  let(:filename) { 'maintenance' }
  let(:path) { File.expand_path("../../fixtures/#{filename}.yml", __FILE__) }
  let(:maint_file) { Turnout::MaintenanceFile.new(path) }
  subject { maint_file }

  context 'with a missing file' do
    let(:filename) { 'nope' }

    its(:exists?) { should be_false }
    its(:reason) { should eql "The site is temporarily down for maintenance.\nPlease check back soon." }
    its(:allowed_paths) { should eql [] }
    its(:allowed_ips) { should eql [] }
    its(:response_code) { should eql 503 }
  end

  context 'with an existant file' do
    its(:exists?) { should be_true }
    its(:reason) { should eql 'Oopsie!'  }
    its(:allowed_paths) { should eql ['/uuddlrlrba.*'] }
    its(:allowed_ips) { should eql ['10.0.0.42', '192.168.1.0/24'] }
    its(:response_code) { should eql 418 }

    describe '#to_h' do
      let(:hash) { maint_file.to_h }

      its(:to_h) { should be_a Hash }
      it { expect(hash.keys).to eql [:reason, :allowed_paths, :allowed_ips, :response_code] }
      it { expect(hash[:reason]).to eql 'Oopsie!' }
      it { expect(hash[:allowed_paths]).to eql ['/uuddlrlrba.*'] }
      it { expect(hash[:allowed_ips]).to eql ['10.0.0.42', '192.168.1.0/24'] }
      it { expect(hash[:response_code]).to eql 418 }
    end

    describe '#to_yaml' do
      let(:yaml) { YAML::load(maint_file.to_yaml) }
      subject { yaml }

      its(:to_yaml) { should be_a String }
      it { expect(yaml.keys).to eql ['reason', 'allowed_paths', 'allowed_ips', 'response_code'] }
      it { expect(yaml['reason']).to eql 'Oopsie!' }
      it { expect(yaml['allowed_paths']).to eql ['/uuddlrlrba.*'] }
      it { expect(yaml['allowed_ips']).to eql ['10.0.0.42', '192.168.1.0/24'] }
      it { expect(yaml['response_code']).to eql 418 }
    end
  end

  describe '#write' do
    let(:path) { '/tmp/bogus' }

    it 'writes the file' do
      file = double('file')
      File.should_receive(:open).with('/tmp/bogus', 'w').and_yield(file)
      file.should_receive(:write).with(maint_file.to_yaml)

      maint_file.write
    end
  end

  describe '#delete' do
    it 'deletes the file' do
      File.should_receive(:delete).with(path)
      maint_file.delete
    end
  end

  describe '#import' do
    let(:env_vars) { {} }
    before { maint_file.import_env_vars(env_vars) }

    it { expect(maint_file.import_env_vars({})).to be_true }

    context 'with reason set' do
      let(:env_vars) { {'reason' => 'I made a boo boo'} }
      its(:reason) { should eql 'I made a boo boo' }
    end

    context 'with allowed_paths set' do
      let(:env_vars) { {'allowed_paths' => 'some/path,other/path'} }
      its(:allowed_paths) { should eql ['some/path', 'other/path'] }
    end

    context 'with allowed_ips set' do
      let(:env_vars) { {'allowed_ips' => '10.0.0.1/24,127.0.0.1'} }
      its(:allowed_ips) { should eql ['10.0.0.1/24', '127.0.0.1'] }
    end

    context 'with response_code set' do
      let(:env_vars) { {'response_code' => 418} }
      its(:response_code) { should eql 418 }
    end
  end

  describe '.find' do
    subject { Turnout::MaintenanceFile.find }

    context 'when a file exists' do
      before { Turnout.config.named_maintenance_file_paths = {fixture: 'spec/fixtures/maintenance.yml'} }
      it { should be_a Turnout::MaintenanceFile }
    end

    context 'when no file exists' do
      before { Turnout.config.named_maintenance_file_paths = {nope: 'spec/fixtures/nope.yml'} }
      it { should be_nil }
    end
  end

  describe '.named' do
    subject { Turnout::MaintenanceFile.named(name) }

    before { Turnout.config.named_maintenance_file_paths = {valid: 'spec/fixtures/nope.yml'} }

    context 'when a valid name' do
      let(:name) { :valid }
      it { should be_a Turnout::MaintenanceFile }
    end

    context 'when an invalid name' do
      let(:name) { :invalid }
      it { should be_nil }
    end
  end

  describe '.default' do
    subject { Turnout::MaintenanceFile.default }
    it { should be_a Turnout::MaintenanceFile }
  end
end