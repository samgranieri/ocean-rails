require 'spec_helper'

describe TheModelsController do

  before :each do
  	@i = TheModelsController.new
  	@c = @i.class
  end

  after :each do
    @c.ocean_resource_controller   # Restore class defaults
  end


  it "should be available as a class method from any controller" do
  	@c.ocean_resource_controller
  end



  it "should accept an :extra_actions keyword arg" do
    @c.ocean_resource_controller extra_actions: {foo: [], bar: []}
    @c.ocean_resource_controller extra_actions: {}
  end

  it ":extra_actions should default to {}" do
  	@c.ocean_resource_controller
  	@c.ocean_resource_controller_extra_actions.should == {}
  end

  it ":extra_actions should be reachable through a class method" do
  	@c.ocean_resource_controller extra_actions: {foo: [], bar: []}
  	@c.ocean_resource_controller_extra_actions.should == {foo: [], bar: []}
    @c.ocean_resource_controller   # Restore class defaults
 end

  it "instances should have an extra_actions method" do
  	@c.ocean_resource_controller extra_actions: {gniff: [], gnoff: []}
  	@i.extra_actions.should == {gniff: [], gnoff: []}
  end



  it "should accept a :required_attributes keyword arg" do
    @c.ocean_resource_controller required_attributes: [:quux, :snarf]
  end

  it ":required_attributes should default to [:lock_version, :name, :description]" do
    @c.ocean_resource_controller
    @c.ocean_resource_controller_required_attributes.should == [:lock_version, :name, :description]
  end
  
  it ":required_attributes should be reachable through a class method" do
    @c.ocean_resource_controller required_attributes: [:quux, :snarf]
    @c.ocean_resource_controller_required_attributes.should == [:quux, :snarf]
  end


  it "should accept a :permitted_attributes keyword arg" do
    @c.ocean_resource_controller permitted_attributes: [:quux, :snarf]
  end

  it ":permitted_attributes should default to []" do
    @c.ocean_resource_controller
    @c.ocean_resource_controller_permitted_attributes.should == []
  end
  
  it ":permitted_attributes should be reachable through a class method" do
    @c.ocean_resource_controller permitted_attributes: [:gnik, :gnok]
    @c.ocean_resource_controller_permitted_attributes.should == [:gnik, :gnok]
  end


  it "should accept a :no_validation_errors_on keyword arg" do
    @c.ocean_resource_controller no_validation_errors_on: [:blipp, :blopp]
  end

  it ":no_error_data_on should default to []" do
    @c.ocean_resource_controller
    @c.ocean_resource_controller_no_validation_errors_on.should == []
  end

  it ":no_error_data_on should be reachable through a class method" do
    @c.ocean_resource_controller no_validation_errors_on: [:password_hash, :password_salt]
    @c.ocean_resource_controller_no_validation_errors_on.should == [:password_hash, :password_salt]
  end


  it "instances should have a missing_attributes? method" do
  	@c.ocean_resource_controller required_attributes: [:blirg, :blorg, :gnikk]
    @i.params = {blirg: 2, blorggh: 3, fnyyk: 4}
  	@i.missing_attributes?.should == true
  end

end
