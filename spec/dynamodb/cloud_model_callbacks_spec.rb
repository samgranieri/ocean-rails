require 'spec_helper'


describe CloudModel do

  it "should support the after_initialize callback" do
    CloudModel.new.uuid.should be_a String
  end

  it "should support the before_validation callback" do
    i = CloudModel.new
    i.destroy_at.should == nil
    i.valid?
    i.destroy_at.should be_a Time
  end

  it "should support the after_validation callback"

  it "should support the before_save callback"

  it "should support the before_create callback"

  it "should support the after_create callback"

  it "should support the before_update callback"

  it "should support the after_update callback"

  it "should support the after_save callback"

  it "should support the after_commit callback"

  it "should support the after_find callback"

  it "should support the around_save callback"

  it "should support the around_create callback"

  it "should support the around_update callback"

  it "should support the around_destroy callback"

end
