require 'spec_helper'

class TestRequest
  attr_accessor :ip, :path

  def initialize(params)
    self.ip = "127.0.0.1"
    self.path = "/sample_path"
  end
end

describe Rack::Turnout do
  before(:each) do
    @app = double("app")
    @turnout = Rack::Turnout.new(@app)
  end

  context "path_allowed?" do
    it "should return true is paths match" do
      settings = {"reason"=>nil, "allowed_paths"=>["/valid_path"], "denied_paths"=>[], "allowed_ips"=>[]}

      @turnout.stub(:settings).and_return(settings)
      @turnout.send(:path_allowed?, '/valid_path').should be_true
    end

    it "should return false is paths don't match" do
      settings = {"reason"=>nil, "allowed_paths"=>["/valid_path"], "denied_paths"=>[], "allowed_ips"=>[]}

      @turnout.stub(:settings).and_return(settings)
      @turnout.send(:path_allowed?, '/invalid_path').should be_false
    end

    it "should return false if allowed paths is empty" do
      settings = {"reason"=>nil, "allowed_paths"=>[], "denied_paths"=>[], "allowed_ips"=>[]}

      @turnout.stub(:settings).and_return(settings)
      @turnout.send(:path_allowed?, '/valid_path').should be_false
    end
  end

  context "path_denied?" do

    it "should return true is paths match" do
      settings = {"reason"=>nil, "allowed_paths"=>[], "denied_paths"=>["/blocked_path"], "allowed_ips"=>[]}

      @turnout.stub(:settings).and_return(settings)
      @turnout.send(:path_denied?, '/blocked_path').should be_true
    end

    it "should return false is paths don't match" do
      settings = {"reason"=>nil, "allowed_paths"=>[], "denied_paths"=>["/blocked_path"], "allowed_ips"=>[]}

      @turnout.stub(:settings).and_return(settings)
      @turnout.send(:path_denied?, '/valid_path').should be_false
    end

    it "should return false if denied paths is empty" do
      settings = {"reason"=>nil, "allowed_paths"=>[], "denied_paths"=>[], "allowed_ips"=>[]}

      @turnout.stub(:settings).and_return(settings)
      @turnout.send(:path_denied?, '/valid_path').should be_false
    end

  end

  context "on?" do
    before(:each) do
      @env = double("env")
      @request = TestRequest.new(:ip => '127.0.0.1', :path => '/sample_path')
      Rack::Request.stub(:new).and_return(@request)

      @turnout.stub(:ip_allowed?).and_return(false)
    end

    it "should return false when nothing active" do
      settings = {"reason"=>nil, "allowed_paths"=>[], "denied_paths"=>[], "allowed_ips"=>[]}
      @turnout.stub(:settings).and_return(settings)

      @turnout.send(:on?, @env).should be_false
    end

    it "should return true when denied path is active" do
      settings = {"reason"=>nil, "allowed_paths"=>[], "denied_paths"=>["/sample_path"], "allowed_ips"=>[]}
      @turnout.stub(:settings).and_return(settings)
      
      @turnout.send(:on?, @env).should be_true
    end

    it "should return false when allowed paths is active" do
      settings = {"reason"=>nil, "allowed_paths"=>["/sample_path"], "denied_paths"=>[], "allowed_ips"=>[]}
      @turnout.stub(:settings).and_return(settings)
      
      @turnout.send(:on?, @env).should be_false
    end

    it "should return false when there are no settings" do
      settings = {}
      @turnout.stub(:settings).and_return(settings)
      
      @turnout.send(:on?, @env).should be_false
    end
  end
end