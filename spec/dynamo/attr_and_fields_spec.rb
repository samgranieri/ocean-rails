require 'spec_helper'


describe CloudModel do

  it_should_behave_like "ActiveModel"

  it "should be instantiatable" do
    CloudModel.new.should be_a CloudModel
  end


  it "should have a class method table_hash_key" do
    CloudModel.table_hash_key.should == :uuid
  end

  it "should have a class method table_range_key" do
    CloudModel.table_range_key.should == false
  end

  it "should barf on a missing primary key at instantiation" do
     expect { CloudModel.new }.not_to raise_error
     CloudModel.table_hash_key = false
     expect { CloudModel.new }.to raise_error
     CloudModel.table_hash_key = :uuid   # We restore the expected value, as classes aren't reloaded between tests
  end


  it "should be possible to refer to the hash_key field using #id, regardless of its name" do
    i = CloudModel.new uuid: "blahonga"
    i.uuid.should == "blahonga"
    i.id.should == "blahonga"
  end

  it "should be possible to set the hash_key field using #id, regardless of its name" do
    i = CloudModel.new uuid: "blahonga"
    i.id.should == "blahonga"
    i.id = "snyko"
    i.uuid.should == "snyko"
  end


  it "should have a class method read_capacity_units to set the table_read_capacity_units class attr" do
    CloudModel.table_read_capacity_units.should == 10
    CloudModel.read_capacity_units(111).should == 111
    CloudModel.table_read_capacity_units.should == 111
    CloudModel.table_read_capacity_units = 10           # Restore
  end

  it "table_read_capacity_units should default to 10" do
    CloudModel.table_read_capacity_units.should == 10
  end


  it "should have a class method write_capacity_units to set the table_write_capacity_units class attr" do
    CloudModel.table_write_capacity_units.should == 5
    CloudModel.write_capacity_units(222).should == 222
    CloudModel.table_write_capacity_units.should == 222
    CloudModel.table_write_capacity_units = 5           # Restore
  end

  it "table_write_capacity_units should default to 5" do
    CloudModel.table_write_capacity_units.should == 5
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

  it "should have a method assign_attributes" do
    i = CloudModel.new
    i.assign_attributes token: "changed", default_poison_limit: 10
    i.token.should == "changed"
    i.default_poison_limit.should == 10
  end


  it "should assign the fields values supplied in the call to new" do
    i = CloudModel.new uuid: "Barack-Obladiobladama", created_by: "http://somewhere"
    i.uuid.should == "Barack-Obladiobladama"
    i.created_by.should == "http://somewhere"
  end

  it "should set defaults for field values not supplied in the call to new" do
    i = CloudModel.new
    i.default_poison_limit.should == 5
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


  it "to_key should return nil when the instance hasn't been persisted" do
    CloudModel.any_instance.should_receive(:persisted?).and_return(false)
    CloudModel.new.to_key.should == nil
  end

  it "to_key should return an array of the present index key when the instance has been persisted" do
    CloudModel.any_instance.should_receive(:persisted?).and_return(true)
    i = CloudModel.new
    i.to_key.should == [i.uuid]
  end

  it "@i[:foo] and @i['foo'] should be equivalent to @i.foo" do
    i = CloudModel.new uuid: "trala"
    i[:uuid].should == "trala"
    i['uuid'].should == "trala"
  end

  it "@i[:foo]= and @i['foo']= should be equivalent to @i.foo=" do
    i = CloudModel.new uuid: "trala"
    i[:uuid] = "wow"
    i[:uuid].should == "wow"
    i['uuid'] = "yowza"
    i['uuid'].should == "yowza"
  end

  # it "should implement <<" do
  #   i = CloudModel.new
  #   i.steps.should == []
  #   i.steps << 1
  #   i.steps.should == [1]
  #   i.steps << 2
  #   i.steps.should == [2]
  #   i.steps << 3
  #   i.steps.should == [3]
  # end

end
