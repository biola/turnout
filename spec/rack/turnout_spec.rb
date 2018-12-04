require 'spec_helper'

describe 'Rack::Turnout' do
  let(:endpoint) { TestApp.new }
  let(:app) { Rack::Turnout.new(endpoint) }

  context 'redis client maintenance page' do
    subject{ get '/any_path' }
    its(:status) {
      allow(Turnout::RedisClient).to receive(:maintenance?).and_return(true)
      should eql 503 }
    its(:body) {
      allow(Turnout::RedisClient).to receive(:maintenance?).and_return(true)
      should_not eql 'Hello World!' }
    its(:body) {
      allow(Turnout::RedisClient).to receive(:maintenance?).and_return(true)
      should match 'Down for Maintenance' }
  end

  context 'without a maintenance.yml file' do
    subject { get '/any_path' }
    its(:status) { should eql 200 }
    its(:body) { should eql 'Hello World!' }
  end

  context 'with a maintenance.yml file' do
    before { Turnout.config.named_maintenance_file_paths = {fixture: 'spec/fixtures/maintenance.yml'} }
    # maintenance.yml:
    #   reason: Oopsie!
    #   allowed_paths: [/uuddlrlrba.*]
    #   allowed_ips:
    #     - 10.0.0.42
    #     - 192.168.1.0/24
    #   response_code: 418
    #   retry_after: 3600

    context 'with allowed_paths set' do
      describe 'request to allowed path' do
        subject { get '/uuddlrlrba' }
        its(:status) { should eql 200 }
        its(:body) { should eql 'Hello World!' }
      end

      describe "request to path that isn't allowed" do
        subject { get '/some_other_path' }
        its(:status) { should eql 418 }
        its(:body) { should_not eql 'Hello World!' }
      end
    end

    context 'with response_code set' do
      describe "request to any path" do
        subject { get '/any_path' }
        its(:status) { should eql 418 }
      end
    end

    context 'with retry_after set' do
      describe "request to any path" do
        subject { get '/any_path' }
        its(:headers) { should include('Retry-After' => '3600') }
      end
    end

    context 'with allowed_ips set' do
      describe 'request from allowed IP' do
        subject { get '/any_path', {}, 'REMOTE_ADDR' => '10.0.0.42' }
        its(:status) { should eql 200 }
        its(:body) { should eql 'Hello World!' }
      end

      describe 'request from an IP in the allowed range' do
        subject { get '/any_path', {}, 'REMOTE_ADDR' => '192.168.1.42' }
        its(:status) { should eql 200 }
        its(:body) { should eql 'Hello World!' }
      end

      describe "request from IP that isn't allowed" do
        subject { get '/any_path', {}, 'REMOTE_ADDR' => '10.0.0.255' }
        its(:status) { should eql 418 }
        its(:body) { should_not eql 'Hello World!' }
      end
    end

    context 'with a reason set' do
      subject { get '/any_path' }
      its(:body) { should match 'Oopsie!' }
      its(['Content-Type']) { should eql 'text/html' }
    end

    context 'json' do
      subject { get '/any_path', nil, { 'HTTP_ACCEPT' => 'application/json' } }

      its(:status) { should eql 418 }
      its(:body) { should match '{"error":"Service Unavailable","message":"' }
      its(['Content-Type']) { should eql 'application/json' }

      context 'with a reason set' do
        its(:body) { should match '{"error":"Service Unavailable","message":"Oopsie!"}' }
      end
    end
  end
end
