require 'spec_helper'

describe TheModelsController do
  
  render_views

  describe "INDEX" do
    
    before :each do
      permit_with 200
      Api.stub(:call_p)
      create :the_model
      create :the_model
      create :the_model
      request.headers['HTTP_ACCEPT'] = "application/json"
      request.headers['X-API-Token'] = "boy-is-this-fake"
    end

    
    it "should return JSON" do
      get :index
      response.content_type.should == "application/json"
    end
    
    it "should return a 400 if the X-API-Token header is missing" do
      request.headers['X-API-Token'] = nil
      get :index
      response.status.should == 400
      response.content_type.should == "application/json"
    end
    
    it "should return a 200 when successful" do
      get :index
      response.status.should == 200
      response.should render_template(partial: "_the_model", count: 3)
    end

    it "should return a collection" do
      get :index
      response.status.should == 200
      coll = JSON.parse(response.body)
      coll.should be_an Array
      coll.length.should == 3
    end

    it "should handle the empty array" do
      TheModel.destroy_all
      controller.should_not_receive(:render_to_string)
      get :index
      response.status.should == 200
      coll = JSON.parse(response.body)
      coll.should be_an Array
      coll.length.should == 0
    end

    it "should return a paged collection" do
      get :index, page_size: 30, page: 0
      response.status.should == 200
      JSON.parse(response.body).should be_an Array
      JSON.parse(response.body).count.should == 3
    end

  end
  
end
