require 'spec_helper'

require 'base64'


describe Api do
  
  it "should have a class method to return the API version for a service" do
    Api.version_for(:auth).should match /v[0-9]+/
  end


  describe "authenticate" do

    it "should have an accessor to get the current authentication token" do
      Api.stub(:post).
        and_return(double(status: 201,
                          body: {'authentication' => {'token' => "this-is-the-authentication-token"}}))
      Api.authenticate
      Api.token.should == "this-is-the-authentication-token"
    end

    it "should raise an exception if the return status isn't 201, 400, 403, or 500" do
      Api.stub(:post).and_return(double(status: 666))
      lambda { Api.authenticate }.should raise_error("Authentication weirdness")
    end
  end


  describe ".call" do

    it "should handle GET" do
      stub_request(:get, "http://example.com/v1/api_users").
         with(headers: {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'X-API-Token'=>"sjhdfsd"}).
         to_return(status: 200, headers: {'Content-Type'=>'application/json'}, body: '{"x":2,"y":1}')
      response = Api.call "http://example.com", :get, 'api_user', "/api_users", {}, {x_api_token: "sjhdfsd"}
      response.status.should == 200
      response.headers.should == {"content-type"=>"application/json"}
      response.body.should == {"x"=>2, "y"=>1}
    end

    it "should handle POST" do
      stub_request(:post, "http://example.com/v1/api_users").
         with(headers: {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'X-API-Token'=>"sjhdfsd"},
              body: "this is the body").
         to_return(status: 201, body: '{"x":2,"y":1}', headers: {'Content-Type'=>'application/json'})
      response = Api.call "http://example.com", :post, 'api_user', "/api_users", "this is the body", {x_api_token: "sjhdfsd"}
      response.status.should == 201
      response.headers.should == {"content-type"=>"application/json"}
      response.body.should == {"x"=>2, "y"=>1}
   end

    it "should handle PUT" do
      stub_request(:put, "http://example.com/v1/api_users").
         with(headers: {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'X-API-Token'=>"sjhdfsd"},
              body: "this is the body").
         to_return(status: 200, body: '{"x":2,"y":1}', headers: {'Content-Type'=>'application/json'})
      response = Api.call "http://example.com", :put, 'api_user', "/api_users", "this is the body", {x_api_token: "sjhdfsd"}
      response.status.should == 200
      response.headers.should == {"content-type"=>"application/json"}
      response.body.should == {"x"=>2, "y"=>1}
    end

    it "should handle DELETE" do
      stub_request(:delete, "http://example.com/v1/api_users").
         with(headers: {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'X-API-Token'=>"sjhdfsd"}).
         to_return(status: 200, body: '', headers: {'Content-Type'=>'application/json'})
      response = Api.call "http://example.com", :delete, 'api_user', "/api_users", {}, {x_api_token: "sjhdfsd"}
      response.status.should == 200
      response.headers.should == {"content-type"=>"application/json"}
      response.body.should == nil
   end

    it "should handle PURGE" do
      stub_request(:purge, "http://example.com/v1/api_users").
         with(headers: {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
         to_return(status: 200, body: '', headers: {'Content-Type'=>'application/json'})
      response = Api.call "http://example.com", :purge, 'api_user', "/api_users"
      response.status.should == 200
      response.headers.should == {"content-type"=>"application/json"}
      response.body.should == nil
   end

    it "should handle BAN" do
      stub_request(:ban, "http://example.com/v1/api_users").
         with(headers: {'Accept'=>'application/json', 'Content-Type'=>'application/json'}).
         to_return(status: 200, body: '', headers: {'Content-Type'=>'application/json'})
      response = Api.call "http://example.com", :ban, 'api_user', "/api_users"
      response.status.should == 200
      response.headers.should == {"content-type"=>"application/json"}
      response.body.should == nil
    end

  end


  it "Api.get should use Api.call" do
    stub_request(:get, "http://forbidden.example.com/v1/api_users/1/groups").
      with(headers: {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'X-API-Token'=>"sjhdfsd"}).
      to_return(status: 200, body: '{"x":2,"y":1}', headers: {'Content-Type'=>'application/json'})
    response = Api.get(:api_users, "/api_users/1/groups", {}, {x_api_token: "sjhdfsd"})
    response.status.should == 200
    response.headers.should == {"content-type"=>"application/json"}
    response.body.should == {"x"=>2, "y"=>1}
  end

  it "Api.post should use Api.call" do
    stub_request(:post, "http://forbidden.example.com/v1/api_users/1/groups").
      with(body: "this is the body",
           headers: {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'X-Api-Token'=>'sjhdfsd'}).
      to_return(status: 200, body: '{"x":2,"y":1}', headers: {'Content-Type'=>'application/json'})
    response = Api.post(:api_users, "/api_users/1/groups", "this is the body", {x_api_token: "sjhdfsd"})
    response.status.should == 200
    response.headers.should == {"content-type"=>"application/json"}
    response.body.should == {"x"=>2, "y"=>1}
  end

  it "Api.put should use Api.call" do
    stub_request(:put, "http://forbidden.example.com/v1/api_users/1/groups").
      with(body: "this is the body",
           headers: {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'X-Api-Token'=>'sjhdfsd'}).
      to_return(status: 200, body: '{"x":2,"y":1}', headers: {'Content-Type'=>'application/json'})
    response = Api.put(:api_users, "/api_users/1/groups", "this is the body", {x_api_token: "sjhdfsd"})
    response.status.should == 200
    response.headers.should == {"content-type"=>"application/json"}
    response.body.should == {"x"=>2, "y"=>1}
  end

  it "Api.delete should use Api.call" do
    stub_request(:delete, "http://forbidden.example.com/v1/api_users/1/groups").
      with(headers: {'Accept'=>'application/json', 'Content-Type'=>'application/json', 'X-API-Token'=>"sjhdfsd"}).
      to_return(status: 200, body: '', headers: {'Content-Type'=>'application/json'})
    response = Api.delete(:api_users, "/api_users/1/groups", {}, {x_api_token: "sjhdfsd"})
    response.status.should == 200
    response.headers.should == {"content-type"=>"application/json"}
    response.body.should == nil
  end


  it ".decode_credentials should be able to decode what .encode_credentials produces" do
    Api.decode_credentials(Api.encode_credentials("foo", "bar")).should == ["foo", "bar"]
  end

  it ".encode_credentials should encode username and password into Base64 form" do
    Api.encode_credentials("myuser", "mypassword").should ==
      ::Base64.strict_encode64("myuser:mypassword")
  end

  it ".decode_credentials should decode username and password from Base64" do
    Api.decode_credentials(::Base64.strict_encode64("myuser:mypassword")).should == 
      ['myuser', 'mypassword']
  end

  it ".decode_credentials, when given nil, should return empty credentials" do
    Api.decode_credentials(nil).should == ['', '']
  end
  
  
  describe ".permitted?" do
    
    it "should return a response with a status of 404 if the token is unknown" do
      Api.stub(:get).and_return(double(:status => 404))
      Api.permitted?('some-client-token').status.should == 404
    end
    
    it "should return a response with a status of 400 if the authentication has expired" do
      Api.stub(:get).and_return(double(:status => 400))
      Api.permitted?('some-client-token').status.should == 400
    end    
  
    it "should return a response with a status of 403 if the operation is denied" do
      Api.stub(:get).and_return(double(:status => 403))
      Api.permitted?('some-client-token').status.should == 403
    end
    
    it "should return a response with a status of 200 if the operation is authorized" do
      Api.stub(:get).and_return(double(:status => 200))
      Api.permitted?('some-client-token').status.should == 200
    end
  end


  describe "class method authorization_string" do

    it "should take the extra actions, the controller name and an action name" do
      Api.authorization_string({}, "fubars", "show").should be_a(String)
    end

    it "should take an optional app and an optional context" do
      Api.authorization_string({}, "fubars", "show", "some_app", "some_context").should be_a(String)
    end

    it "should put the app and context in the two last positions" do
      qs = Api.authorization_string({}, "fubars", "show", "some_app", "some_context").split(':')
      qs[4].should == 'some_app'
      qs[5].should == 'some_context'
    end

    it "should replace a blank app or context with asterisks" do
      qs = Api.authorization_string({}, "fubars", "show", nil, " ").split(':')
      qs[4].should == '*'
      qs[5].should == '*'
    end

    it "should take an optional service name" do
      Api.authorization_string({}, "fubars", "show", "*", "*", "foo").should == "foo:fubars:self:GET:*:*"
    end

    it "should default the service name to APP_NAME" do
      Api.authorization_string({}, "fubars", "show", "*", "*").should == "#{APP_NAME}:fubars:self:GET:*:*"
    end

    it "should return a string of six colon-separated parts" do
      qs = Api.authorization_string({}, "fubars", "show")
      qs.should be_a(String)
      qs.split(':').length.should == 6
    end

    it "should use the controller name as the resource name" do
      qs = Api.authorization_string({}, "fubars", "show", nil, nil, 'foo').split(':')
      qs[1].should == "fubars"
    end
  end


  describe "class method map_authorization" do

    it "should return an array of two strings" do
      m = Api.map_authorization({}, "fubars", "show")
      m.should be_an(Array)
      m.length.should == 2
      m[0].should be_a(String)
      m[1].should be_a(String)
    end

    it "should translate 'show'" do
      Api.map_authorization({}, "fubars", "show").should == ["self", "GET"]
    end

    it "should translate 'index'" do
      Api.map_authorization({}, "fubars", "index").should == ["self", "GET*"]
    end

    it "should translate 'create'" do
      Api.map_authorization({}, "fubars", "create").should == ["self", "POST"]
    end

    it "should translate 'update'" do
      Api.map_authorization({}, "fubars", "update").should == ["self", "PUT"]
    end

    it "should translate 'destroy'" do
      Api.map_authorization({}, "fubars", "destroy").should == ["self", "DELETE"]
    end

    it "should translate 'connect'" do
      Api.map_authorization({}, "fubars", "connect").should == ["connect", "PUT"]
    end

    it "should translate 'disconnect'" do
      Api.map_authorization({}, "fubars", "disconnect").should == ["connect", "DELETE"]
    end

    it "should raise an error for unknown actions" do
      expect { Api.map_authorization({}, "fubars", "blahonga") }.to raise_error
    end

    it "should insert the extra_action data appropriately" do
      Api.map_authorization({'fubars' => {'blahonga_create' => ['blahonga', 'POST']}}, 
                             "fubars", "blahonga_create").
        should == ['blahonga', 'POST']
    end
  end
     
  
  describe ".adorn_basename" do

    before :all do
      @local_ip = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}.gsub('.', '-')
    end

    it "should return a string" do
      Api.adorn_basename("SomeBaseName").should be_a String
    end

    it "should return a string containing the basename" do
      Api.adorn_basename("SomeBaseName").should include "SomeBaseName"
    end

    it "should return a string containing the Chef environment" do
      Api.adorn_basename("SomeBaseName", chef_env: "zuul").should include "zuul"
    end

    it "should add only the Chef env if the Rails env is production" do
      Api.adorn_basename("Q", chef_env: "prod", rails_env: 'production').should ==     "Q_prod"
      Api.adorn_basename("Q", chef_env: "staging", rails_env: 'production').should ==  "Q_staging"
      Api.adorn_basename("Q", chef_env: "master", rails_env: 'production').should ==   "Q_master"
    end

    it "should add IP and rails_env if the chef_env is 'dev' or 'ci' or if rails_env isn't 'production'" do
      Api.adorn_basename("Q", chef_env: "dev",  rails_env: 'development').should ==    "Q_dev_#{@local_ip}_development"
      Api.adorn_basename("Q", chef_env: "dev",  rails_env: 'test').should ==           "Q_dev_#{@local_ip}_test"
      Api.adorn_basename("Q", chef_env: "dev",  rails_env: 'production').should ==     "Q_dev_#{@local_ip}_production"
      Api.adorn_basename("Q", chef_env: "ci",   rails_env: 'development').should ==    "Q_ci_#{@local_ip}_development"
      Api.adorn_basename("Q", chef_env: "ci",   rails_env: 'test').should ==           "Q_ci_#{@local_ip}_test"
      Api.adorn_basename("Q", chef_env: "ci",   rails_env: 'production').should ==     "Q_ci_#{@local_ip}_production"
      Api.adorn_basename("Q", chef_env: "master", rails_env: 'development').should ==  "Q_master_#{@local_ip}_development"
      Api.adorn_basename("Q", chef_env: "master", rails_env: 'test').should ==         "Q_master_#{@local_ip}_test"
      Api.adorn_basename("Q", chef_env: "staging", rails_env: 'development').should == "Q_staging_#{@local_ip}_development"
      Api.adorn_basename("Q", chef_env: "staging", rails_env: 'test').should ==        "Q_staging_#{@local_ip}_test"
      Api.adorn_basename("Q", chef_env: "staging", rails_env: 'production').should ==  "Q_staging"
      Api.adorn_basename("Q", chef_env: "prod", rails_env: 'development').should ==    "Q_prod_#{@local_ip}_development"
      Api.adorn_basename("Q", chef_env: "prod", rails_env: 'test').should ==           "Q_prod_#{@local_ip}_test"
    end

    it "should leave out the basename if :suffix_only is true" do
      Api.adorn_basename("Q", chef_env: "prod", rails_env: 'production', suffix_only: true).
        should == "_prod"
      Api.adorn_basename("Q", chef_env: "prod", rails_env: 'development', suffix_only: true).
        should == "_prod_#{@local_ip}_development"
    end
  end


  describe ".basename_suffix" do

    it "should return a string" do
      Api.basename_suffix.should be_a String
    end
  end


  describe ".escape" do

    it "should escape the backslash (\)" do
      Api.escape("\\").should == "%5C"
    end

    it "should escape the pipe (|)" do
      Api.escape("|").should == "%7C"
    end

    it "should escape the backslash (\)" do
      Api.escape("?").should == "%3F"
    end

    it "should not escape dollar signs" do
      Api.escape("$").should == "$"
    end

    it "should not escape slashes (/)" do
      Api.escape("/").should == "/"
    end

    it "should not escape plusses (+)" do
      Api.escape("+").should == "+"
    end

    it "should not escape asterisks" do
      Api.escape("*").should == "*"
    end

    it "should not escape full stops" do
      Api.escape(".").should == "."
    end

    it "should not escape hyphens" do
      Api.escape("-").should == "-"
    end

    it "should not escape underscores" do
      Api.escape("_").should == "_"
    end

    it "should not escape parens" do
      Api.escape("()").should == "()"
    end

    it "should not escape brackets" do
      Api.escape("[]").should == "[]"
    end

    it "should not escape letters or numbers" do
      Api.escape("AaBbCc123").should == "AaBbCc123"
    end

  end

end
