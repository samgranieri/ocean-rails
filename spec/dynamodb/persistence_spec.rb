require 'spec_helper'


describe CloudModel do

  before :all do
    WebMock.allow_net_connect!
    CloudModel.establish_db_connection
  end

  before :each do
    @i = CloudModel.new
  end

  after :all do
    WebMock.disable_net_connect!
  end


  it "should have a predicate destroyed?" do
    @i.destroyed?.should == false
  end

  it "should have a predicate new_record?" do
    @i.new_record?.should == true
  end

  it "should have a predicate persisted?" do
    @i.persisted?.should == false
  end

  it "should have a method reload" do
    @i.update_attributes gratuitous_float: 3333.3333
    @i.gratuitous_float.should == 3333.3333
    @i.gratuitous_float = 0.0
    @i.reload(consistent: true).should == @i
    @i.gratuitous_float.should == 3333.3333
  end

  it "should have a method touch"


  it "should have a method delete"

  it "should have a method increment"
  it "should have a method increment!"

  it "should have a method decrement"
  it "should have a method decrement!"


  it "serialize_attribute should barf on an unknown attribute type" do
    expect { @i.serialize_attribute :quux, 42, {type: :falafel, default: nil} }. 
      to raise_error(DynamoDbModel::UnsupportedType, "falafel")
  end


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

  it "persisted? should return false when the instance is new" do
    @i.persisted?.should == false
  end

  it "persisted? should return true when the instance is neither new nor destroyed" do
    @i.persisted?.should == false
    @i.save!
    @i.persisted?.should == true
  end

  it "persisted? should return false when the instance has been deleted" do
    @i.persisted?.should == false
    @i.destroy
    @i.persisted?.should == false
  end

  it "should set @destroyed when an instance is destroyed" do
    @i.destroyed?.should == false
    @i.destroy
    @i.destroyed?.should == true
  end 

  it "destroy should not attempt to delete a DynamoDB object when the instance hasn't been persisted" do
    @i.dynamo_item.should == nil
    @i.destroy
  end

  it "destroy should attempt to delete a DynamoDB object when the instance has been persisted" do
    @i.save!
    @i.dynamo_item.should be_an AWS::DynamoDB::Item
    @i.dynamo_item.should_receive(:delete)
    @i.destroy
  end

  it "should reset @new_record when an instance has been persisted" do
    @i.new_record?.should == true
    @i.save!
    @i.new_record?.should == false
  end

  it "save should update both created_at and updated_at for new records" do
    @i.created_at.should == nil
    @i.updated_at.should == nil
    @i.save
    @i.created_at.should be_a Time
    @i.updated_at.should be_a Time
  end

  it "save should update only updated_at for existing records" do
    @i.save!
    cre = @i.created_at
    upd = @i.updated_at
    cre.should == upd
    @i.save!
    @i.created_at.should == cre
    @i.updated_at.should_not == @i.created_at
  end

  it "should have a class method create" do
    i = CloudModel.create
    i.persisted?.should == true
  end

  it "should have a class method create!" do
    i = CloudModel.create!
    i.persisted?.should == true
  end

  it "should have a method update_attributes" do
    @i.created_by.should == "Peter"
    @i.finished_at.should == nil
    @i.update_attributes(created_by: "Egon", finished_at: Time.now).should == true
    @i.created_by.should == "Egon"
    @i.finished_at.should be_a Time
  end

  it "update_attributes should not barf on an invalid record" do
    @i.update_attributes(uuid: nil).should == false
  end

  it "should have a method update_attributes!" do
    @i.created_by.should == "Peter"
    @i.finished_at.should == nil
    @i.update_attributes!(created_by: "Egon", finished_at: Time.now).should == true
    @i.created_by.should == "Egon"
    @i.finished_at.should be_a Time
  end

  it "update_attributes should barf on an invalid record" do
    expect { @i.update_attributes!(uuid: nil) }.to raise_error
  end





end
