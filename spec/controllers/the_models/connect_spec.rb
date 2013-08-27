require 'spec_helper'

describe TheModelsController do
  
  render_views

  describe "PUT connect" do
    
    before :each do
      permit_with 200
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "incredibly-fake!"
      Api.stub(:call_p)
      @u = create :the_model
    end


    it "should return JSON" do
      put :connect, id: @u.id
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      put :connect, id: @u.id
      response.status.should == 400
    end

    it "should return a 404 if the resource can't be found" do
      put :connect, id: -1
      response.status.should == 404
      response.content_type.should == "application/json"
    end

    it "should return a 422 if the href query arg is missing" do
      put :connect, id: @u.id
      response.status.should == 422
      response.body.should == '{"_api_error":["href query arg is missing"]}'
    end

    it "should return a 422 if the href query arg isn't parseable" do
      put :connect, id: @u.id, href: "mnxyzptlk"
      response.status.should == 422
      response.body.should == '{"_api_error":["href query arg isn\'t parseable"]}'
    end

    it "should return a 404 if the href query arg resource can't be found" do
      put :connect, {id: @u.id, href: the_model_url(666)}
      response.status.should == 404
      response.body.should == '{"_api_error":["Resource to connect not found"]}'
    end

    it "should return a 204 and set @connectee and @connectee_class when successful" do
      other = create :the_model
      put :connect, {id: @u.id, href: the_model_url(other)}
      response.status.should == 204
      assigns(:connectee).should == other
      assigns(:connectee_class).should == TheModel
    end
        
  end
  
end
