require 'spec_helper'


describe CloudModel do

  it_should_behave_like "ActiveModel"

  it "should be instantiatable" do
    CloudModel.new.should be_a CloudModel
  end

  

end
