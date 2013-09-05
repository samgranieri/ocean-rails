require 'spec_helper'


describe CloudModel do

  before :all do
    WebMock.allow_net_connect!
    CloudModel.establish_db_connection
  end

  after :all do
    WebMock.disable_net_connect!
  end


  it "should support the after_initialize callback" do
    CloudModel.new.created_by.should == "Peter"
  end

  it "should support the before_validation callback" do
    i = CloudModel.new
    i.destroy_at.should == nil
    i.valid?
    i.destroy_at.should be_a Time
  end

  it "should support the after_validation callback" do
    i = CloudModel.new
    i.default_step_time.should == 30
    i.valid?
    i.default_step_time.should == 60
  end

  it "should support the after_commit callback" do
    # CloudModel.dynamo_table.should_receive(:exists?).and_return(false)
    # CloudModel.should_receive(:create_table)
    CloudModel.establish_db_connection
    i = CloudModel.new uuid: "same-uuid-as-always"
    # i.dynamo_items.should_receive(:create)
    i.started_at.should == nil
    i.save!
    i.started_at.should be_a Time
  end

  it "should support the touch callback"





end
