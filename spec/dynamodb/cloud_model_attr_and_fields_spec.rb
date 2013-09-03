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

  it "should have a :steps field with a type of :serialized and a :default of []" do
    CloudModel.fields[:steps][:type].should == :serialized
    CloudModel.fields[:steps][:default].should == []
  end


  it "should define accessors for all automatically defined fields" do
    i = CloudModel.new
    i.should respond_to :created_at
    i.should respond_to :created_at=
  end

  it "should define accessors for all declared fields" do
    i = CloudModel.new
    i.should respond_to :name
    i.should respond_to :name=
  end

  it "should allow fields to be read and written" do
    i = CloudModel.new
    i.weight.should == nil
    i.weight = 87
    i.weight.should == 87
  end


  it "should set the values supplied in the call to new" do
    i = CloudModel.new name: "Barack Obladiobladama", weight: 200
    i.name.should == "Barack Obladiobladama"
    i.weight.should == 200
  end

  it "should set defaults for value not supplied in the call to new" do
    i = CloudModel.new
    i.steps.should == []
  end


  it "should require the name to be present" do
    CloudModel.new.valid?.should == false
    CloudModel.new(name: "Ed").valid?.should == true
  end


  it "should have an attribute reader with as many elements as there are fields" do
    CloudModel.new.attributes.length.should == CloudModel.fields.length
  end

  it "should not have an attributes writer" do
    expect { CloudModel.new.attributes = {} }.to raise_error
  end

  it "should have string members" do
    CloudModel.new.attributes.should include 'name'
    CloudModel.new.attributes.should include 'created_at'
  end

end
