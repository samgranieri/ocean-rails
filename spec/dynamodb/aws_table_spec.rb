require 'spec_helper'


describe CloudModel do

  before :all do
    #WebMock.allow_net_connect!
  end

  before :each do
    CloudModel.dynamo_client = nil
    CloudModel.dynamo_table = nil
    CloudModel.dynamo_items = nil
  end

  after :all do
    #WebMock.disable_net_connect!
  end


  it "should have a table_name derived from the class" do
    CloudModel.table_name.should == "cloud_models"
  end

  it "should have a class set_table_name method" do
    CloudModel.set_table_name('bibbedy_babbedy')
    CloudModel.table_name.should == "bibbedy_babbedy"
    CloudModel.set_table_name('cloud_models')  # Restore class var
  end

  it "should have a table_name_prefix" do
    CloudModel.table_name_prefix.should == nil
    CloudModel.table_name_prefix = "foo_"
    CloudModel.table_name_prefix.should == "foo_"
    CloudModel.table_name_prefix = nil         # Restore class var
  end

  it "should have a table_name_suffix" do
    CloudModel.table_name_suffix.should == nil
    CloudModel.table_name_suffix = "_bar"
    CloudModel.table_name_suffix.should == "_bar"
    CloudModel.table_name_suffix = nil         # Restore class var
  end

  it "should have a table_full_name method" do
    CloudModel.table_full_name.should == "cloud_models"
    CloudModel.table_name_prefix = "foo_"
    CloudModel.table_name_suffix = "_bar"
    CloudModel.table_full_name.should == "foo_cloud_models_bar"
    CloudModel.table_name_prefix = nil         # Restore class var
    CloudModel.table_name_suffix = nil         # Restore class var
  end

  it "should have a dynamo_table class_variable" do
    CloudModel.dynamo_table
    CloudModel.new.dynamo_table
    CloudModel.dynamo_table = true
    expect { CloudModel.new.dynamo_table = true }.to raise_error
    CloudModel.dynamo_table = nil
  end


  it "establish_connection should set dynamo_client, dynamo_table and dynamo_items" do
    AWS::DynamoDB::Table.any_instance.should_receive(:exists?).and_return(true)
    AWS::DynamoDB::Table.any_instance.should_receive(:status).and_return(:active)
    CloudModel.should_not_receive(:create_table)
    CloudModel.dynamo_client.should == nil
    CloudModel.dynamo_table.should == nil
    CloudModel.dynamo_items.should == nil
    CloudModel.establish_db_connection
    CloudModel.dynamo_client.should be_an AWS::DynamoDB
    CloudModel.dynamo_table.should be_an AWS::DynamoDB::Table
    CloudModel.dynamo_items.should be_an AWS::DynamoDB::ItemCollection
  end

  it "establish_connection should return true if the table exists and is active" do
    AWS::DynamoDB::Table.any_instance.should_receive(:exists?).and_return(true)
    AWS::DynamoDB::Table.any_instance.should_receive(:status).and_return(:active)
    CloudModel.should_not_receive(:create_table)
    CloudModel.establish_db_connection
  end

  it "establish_connection should wait for the table to complete creation" do
    AWS::DynamoDB::Table.any_instance.should_receive(:exists?).and_return(true)
    AWS::DynamoDB::Table.any_instance.should_receive(:status).
      and_return(:creating, :creating, :creating, :creating, :active)
    Object.should_receive(:sleep).with(1).exactly(4).times
    CloudModel.should_not_receive(:create_table)
    CloudModel.establish_db_connection
  end

  it "establish_connection should wait for the table to delete before trying to create it again" do
    AWS::DynamoDB::Table.any_instance.should_receive(:exists?).and_return(true)
    AWS::DynamoDB::Table.any_instance.should_receive(:status).and_return(:deleting)
    AWS::DynamoDB::Table.any_instance.should_receive(:exists?).and_return(true, true, true, false)
    Object.should_receive(:sleep).with(1).exactly(3).times
    CloudModel.should_receive(:create_table).and_return(true)
    CloudModel.establish_db_connection
  end

  it "establish_connection should try to create the table if it doesn't exist" do
    AWS::DynamoDB::Table.any_instance.should_receive(:exists?).and_return(false)
    CloudModel.should_receive(:create_table).and_return(true)
    CloudModel.establish_db_connection
  end

  it "establish_connection should barf on an unknown table status" do
    AWS::DynamoDB::Table.any_instance.should_receive(:exists?).and_return(true)
    AWS::DynamoDB::Table.any_instance.should_receive(:status).twice.and_return(:syphilis)
    CloudModel.should_not_receive(:create_table)
    expect { CloudModel.establish_db_connection }. 
      to raise_error(DynamoDbModel::UnknownTableStatus, "Unknown DynamoDB table status 'syphilis'")
  end

  it "create_table should try to create the table if it doesn't exist" do
    AWS::DynamoDB::Table.any_instance.should_receive(:exists?).and_return(false)
    t = double(AWS::DynamoDB::Table)
    allow(t).to receive(:status).and_return(:creating, :creating, :creating, :active)
    AWS::DynamoDB::TableCollection.any_instance.should_receive(:create).
      with("cloud_models", 
           10, 
           5, 
           hash_key: {uuid: :string}, 
           range_key: false).
      and_return(t)
    Object.should_receive(:sleep).with(1).exactly(3).times
    CloudModel.establish_db_connection
  end


  it "delete_table should return true if the table was :active" do
    AWS::DynamoDB::Table.any_instance.should_receive(:exists?).twice.and_return(true)
    AWS::DynamoDB::Table.any_instance.should_receive(:status).twice.and_return(:active)
    CloudModel.should_not_receive(:create_table)
    AWS::DynamoDB::Table.any_instance.should_receive(:delete)
    CloudModel.establish_db_connection
    CloudModel.delete_table.should == true
  end

  it "delete_table should return false if the table wasn't :active" do
    AWS::DynamoDB::Table.any_instance.should_receive(:exists?).twice.and_return(true)
    AWS::DynamoDB::Table.any_instance.should_receive(:status).and_return(:active, :deleting)
    CloudModel.establish_db_connection
    CloudModel.delete_table.should == false
  end

end
