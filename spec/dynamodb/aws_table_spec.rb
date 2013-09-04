require 'spec_helper'


describe CloudModel do

  it "should have an AWS DynamoDB client" do
    CloudModel.dynamo_client.should be_a AWS::DynamoDB
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

  
end
