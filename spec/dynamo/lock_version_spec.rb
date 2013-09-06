require 'spec_helper'


describe CloudModel do

  it "should have an automatically supplied lock_version field" do
    CloudModel.fields.should include :lock_version
  end

  it "should have a default lock_version value of 0" do
    CloudModel.new.lock_version.should == 0
  end


  it "should use optimistic locking in update"
  it "should use optimistic locking in destroy"
  it "should use optimistic locking in touch"

end
