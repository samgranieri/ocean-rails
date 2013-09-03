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

  it "should have a :token field" do
    CloudModel.fields.should include :token
  end

  it "should have :token field with a defaulted type of String" do
    CloudModel.fields[:token][:type].should == :string
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
    i.should respond_to :uuid
    i.should respond_to :uuid=
  end

  it "should allow fields to be read and written" do
    i = CloudModel.new
    i.token.should == nil
    i.token = "foo"
    i.token.should == "foo"
  end


  it "should set the values supplied in the call to new" do
    i = CloudModel.new uuid: "Barack-Obladiobladama", created_by: "http://somewhere"
    i.uuid.should == "Barack-Obladiobladama"
    i.created_by.should == "http://somewhere"
  end

  it "should set defaults for value not supplied in the call to new" do
    i = CloudModel.new
    i.steps.should == []
    j = CloudModel.new steps: [{}, {}, {}]
    j.steps.should_not == []
  end


  it "should require the uuid to be present" do
    CloudModel.new(uuid: "").valid?.should == false
    CloudModel.new(uuid: "Ed").valid?.should == true
  end


  it "should have an attribute reader with as many elements as there are fields" do
    CloudModel.new.attributes.length.should == CloudModel.fields.length
  end

  it "should not have an attributes writer" do
    expect { CloudModel.new.attributes = {} }.to raise_error
  end

  it "should have string keys" do
    CloudModel.new.attributes.should include 'uuid'
    CloudModel.new.attributes.should include 'created_at'
  end

end
