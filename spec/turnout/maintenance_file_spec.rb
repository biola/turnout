require 'spec_helper'

describe Turnout::MaintenanceFile do
  let(:path) { File.expand_path("../../fixtures/#{filename}.yml", __FILE__) }
  subject { Turnout::MaintenanceFile.new(path) }

  context 'with a missing file' do
    let(:filename) { 'nope' }

    its(:exists?) { should be_false }
    its(:reason) { should eql "The site is temporarily down for maintenance.\nPlease check back soon." }
    its(:allowed_paths) { should eql [] }
    its(:allowed_ips) { should eql [] }
    its(:response_code) { should eql 503 }
  end

  context 'with an existant file' do
    let(:filename) { 'maintenance' }

    its(:exists?) { should be_true }
    its(:reason) { should eql 'Oopsie!'  }
    its(:allowed_paths) { should eql ['/uuddlrlrba'] }
    its(:allowed_ips) { should eql ['42.42.42.42'] }
    its(:response_code) { should eql 418 }
  end
end