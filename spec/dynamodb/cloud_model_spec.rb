require 'spec_helper'


describe CloudModel do

  it_should_behave_like "ActiveModel"

  it "should be instantiatable" do
    CloudModel.new.should be_a CloudModel
  end

  it "class should have an automatically supplied id field" do
    CloudModel.fields.should include :id
  end

  it "class should have an automatically supplied created_at field" do
    CloudModel.fields.should include :created_at
  end

  it "class should have an automatically supplied updated_at field" do
    CloudModel.fields.should include :updated_at
  end

  it "should have a :name field" do
    CloudModel.fields.should include :name
  end

  it "should have :name field with a defaulted type of String" do
    CloudModel.fields[:name][:type].should == :string
  end

  it "should have a :weight field with a type of :float" do
    CloudModel.fields[:weight][:type].should == :float
  end

end
