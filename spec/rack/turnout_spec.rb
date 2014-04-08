require 'spec_helper'

describe 'Rack::Turnout' do
  let(:endpoint) { TestApp.new }
  let(:app) { Rack::Turnout.new(endpoint).tap{|t| t.stub(:settings).and_return(settings)} }
  let(:settings) { {} }

  context 'without a maintenance.yml file' do
    subject { get '/any_path' }
    its(:status) { should eql 200 }
    its(:body) { should eql 'Hello World!' }
  end

  context 'with a maintenance.yml file' do
    before { app.stub(:maintenance_file_exists?).and_return(true) }

    context 'with allowed_paths set' do
      let(:settings) { { 'allowed_paths' => ['/allowed_path'] } }

      describe 'request to allowed path' do
        subject { get '/allowed_path' }
        its(:status) { should eql 200 }
        its(:body) { should eql 'Hello World!' }
      end

      describe "request to path that isn't allowed" do
        subject { get '/some_other_path' }
        its(:status) { should eql 503 }
        its(:body) { should_not eql 'Hello World!' }
      end
    end

    context 'with response_code set' do
      let(:settings) { { "response_code" => '200' } }

      describe "request to any path" do
        subject { get '/any_path' }
        its(:status) { should eql 200 }
      end
    end

    context 'with allowed_ips set' do
      let(:settings) { { 'allowed_ips' => ['10.0.0.42', '192.168.1.0/24'] } }

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
        its(:status) { should eql 503 }
        its(:body) { should_not eql 'Hello World!' }
      end
    end

    context 'with a reason set' do
      let(:settings) { { 'reason' => 'I broke it' } }
      subject { get '/any_path' }
      its(:body) { should match 'I broke it' }
    end
  end
end
