require 'spec_helper'


describe CloudModel do

  before :each do
    @i = CloudModel.new
  end


  it "should have a class method create"
  it "should have a class method create!"

  it "should have a predicate destroyed?" do
    @i.destroyed?.should == false
  end

  it "should have a predicate new_record?" do
    @i.new_record?.should == true
  end

  it "should have a predicate persisted?" do
    @i.persisted?.should == false
  end

  it "should have a method reload"

  it "should have a method touch"

  it "should have a method update_attributes"
  it "should have a method update_attributes!"

  it "should have a method delete"
  it "should have a method destroy"
  it "should have a method destroy_all"

  it "should have a method increment"
  it "should have a method increment!"

  it "should have a method decrement"
  it "should have a method decrement!"


  it "create_or_update should call create if the record is new" do
    CloudModel.any_instance.should_receive(:new_record?).and_return(true)
    @i.should_receive(:create)
    @i.create_or_update.should == true
  end

  it "create_or_update should call update if the record already exists" do
    CloudModel.any_instance.should_receive(:new_record?).and_return(false)
    @i.should_receive(:update)
    @i.create_or_update.should == true
  end

  it "save should call create_or_update and return true" do
    @i.should_receive(:create_or_update).and_return(true)
    @i.save.should == true
  end

  it "save should call create_or_update and return false if RecordInvalid is raised" do
    @i.stub(:create_or_update).and_raise(DynamoDbModel::RecordInvalid)
    @i.save.should == false
  end

  it "save! should raise RecordNotSaved if the record wasn't saved" do
    @i.stub(:create_or_update).and_return(false)
    expect { @i.save! }.to raise_error(DynamoDbModel::RecordNotSaved)
  end

end
