require 'spec_helper'


describe CloudModel do

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
    i = CloudModel.new
    i.started_at.should == nil
    i.save!
    i.started_at.should be_a Time
  end

  it "should support the after_find callback"





end
