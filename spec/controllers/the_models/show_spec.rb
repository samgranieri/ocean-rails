require 'spec_helper'

describe TheModelsController do
  
  render_views


  describe "Unauthorised GET" do

    it "should pass on any _api_errors received from the authorisation call" do
      deny_with 403, "Foo", "Bar", "Baz"
      Api.stub(:call_p)
      @the_model = create :the_model
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "totally-fake"
      get :show, id: @the_model
      response.status.should == 403
      response.content_type.should == "application/json"
      response.body.should == '{"_api_error":["Foo","Bar","Baz"]}'
    end

  end


  describe "GET" do
    
    before :each do
      permit_with 200
      Api.stub(:call_p)
      @the_model = create :the_model
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "totally-fake"
      request.headers['If-None-Match'] = "some-etag-data-received-earlier"
    end


    it "should return JSON" do
      get :show, id: @the_model
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :show, id: @the_model
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 404 when the user can't be found" do
      get :show, id: -1
      response.status.should == 404
      response.content_type.should == "application/json"
    end

    it "should return a 428 if the request isn't conditional" do
      request.headers['If-None-Match'] = nil
      get :show, id: @the_model
      response.status.should == 428
      response.content_type.should == "application/json"
      JSON.parse(response.body).should == {
        "_api_error" => ["Precondition Required", 
                         "If-None-Match and/or If-Modified-Since missing"]
      }
    end
    
    it "should return a 200 when successful" do
      get :show, id: @the_model
      response.status.should == 200
      response.should render_template(partial: "_the_model", count: 1)
    end
    
  end
  
end
