require 'spec_helper'

describe Turnout::Request do
  let(:path) { '/' }
  let(:ip) { '127.0.0.1' }
  let(:env) { Rack::MockRequest.env_for(path, 'REMOTE_ADDR' => ip) }
  let(:request) { Turnout::Request.new(env) }

  describe '#allowed?' do
    let(:file_name) { 'missing' }
    let(:file_path) { File.expand_path("../../fixtures/#{file_name}.yml", __FILE__) }
    let(:settings) { Turnout::MaintenanceConfig.new(file_path) }
    subject { request.allowed?(settings) }

    context 'without a maintenance file' do
      it { should be false}
    end

    context 'with a maintenance file that sets allowed_paths and allowed_ips' do
      # maintenance.yml contains
      #   allowed_paths: [/uuddlrlrba.*]
      #   allowed_ips: [42.42.42.0/24]}
      let(:file_name) { 'maintenance' }

      context 'request for /letmein' do
        it { should be false }
      end

      context 'request for /uuddlrlrbastart' do
        let(:path) { '/uuddlrlrbastart' }
        it { should be true }
      end

      context 'request from 42.42.40.40' do
        let(:ip) { '42.42.40.40' }
        it { should be false }
      end

      context 'request from 10.0.0.42' do
        let(:ip) { '10.0.0.42' }
        it { should be true }
      end
    end
  end

end
