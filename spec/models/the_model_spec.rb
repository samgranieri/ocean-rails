# == Schema Information
#
# Table name: the_models
#
#  id           :integer          not null, primary key
#  name         :string(255)      not null
#  description  :string(255)      default(""), not null
#  lock_version :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  created_by   :integer          default(0), not null
#  updated_by   :integer          default(0), not null
#

require 'spec_helper'

describe TheModel do

  before :each do
    Api.stub(:call_p)
  end

  
  describe "attributes" do
    
    it "should include a name" do
      create(:the_model, name: "the_model_a").name.should == "the_model_a"
    end

    it "should include a description" do
      create(:the_model, name: "blah", description: "A the_model description").description.should == "A the_model description"
    end
    
    it "should include a lock_version" do
      create(:the_model, lock_version: 24).lock_version.should == 24
    end
    
    it "should have a creation time" do
      create(:the_model).created_at.should be_a Time
    end

    it "should have an update time" do
      create(:the_model).updated_at.should be_a Time
    end
  
   it "should have a creator" do
      create(:the_model, created_by: 123).created_by.should be_an Integer
    end

    it "should have an updater" do
      create(:the_model, updated_by: 123).updated_by.should be_an Integer
    end

 end
    

  describe "search" do
  
    describe ".collection" do
    
      before :each do
        create :the_model, name: 'foo', description: "The Foo the_model", 
          created_at: "2013-03-01T00:00:00Z", created_by: 10, score: 10.0
        create :the_model, name: 'bar', description: "The Bar the_model", 
          created_at: "2013-06-01T00:00:00Z", created_by: 20, score: 20.0
        create :the_model, name: 'baz', description: "The Baz the_model", 
          created_at: "2013-06-10T00:00:00Z", created_by: 30, score: 30.0
        create :the_model, name: 'xux', description: "Xux",               
          created_at: "2013-07-01T00:00:00Z", created_by: 40, score: 40.0
      end

    
      it "should return an array of TheModel instances" do
        ix = TheModel.collection
        ix.length.should == 4
        ix[0].should be_a TheModel
      end
    
      it "should allow matches on name" do
        TheModel.collection(name: 'NOWAI').length.should == 0
        TheModel.collection(name: 'bar').length.should == 1
        TheModel.collection(name: 'baz').length.should == 1
      end
      
      it "should allow searches on description" do
        TheModel.collection(search: 'B').length.should == 2
        TheModel.collection(search: 'the_model').length.should == 3
      end

      it "should return an empty collection when using search where it's been disabled" do
        TheModel.stub(index_search_property: false)
        TheModel.collection(search: 'B').length.should == 0
        TheModel.collection(search: 'the_model').length.should == 0
      end
      
      it "key/value pairs not in the index_only array should quietly be ignored" do
        TheModel.collection(name: 'bar', aardvark: 12).length.should == 1
      end

      it "should support pagination" do
        TheModel.collection(page: 0, page_size: 2).order("name DESC").pluck(:name).should == ["xux", "foo"]
        TheModel.collection(page: 1, page_size: 2).order("name DESC").pluck(:name).should == ["baz", "bar"]
        TheModel.collection(page: 2, page_size: 2).should == []
        TheModel.collection(page: -1, page_size: 2).should == []
      end


      it "should allow ranged matches on datetimes" do
        TheModel.collection(created_at: "2013-04-01T00:00:00Z,2013-06-30T00:00:00Z").length.should == 2
        TheModel.collection(created_at: "2013-06-01T00:00:00Z,2013-07-01T00:00:00Z").length.should == 3
        TheModel.collection(created_at: "2013-01-01T00:00:00Z,2013-12-31T23:59:59Z").length.should == 4
      end

      it "should allow ranged matches on integers" do
        TheModel.collection(created_by: "15,35").length.should == 2
        TheModel.collection(created_by: "10,10").length.should == 1
        TheModel.collection(created_by: "100,200").length.should == 0
      end
        
      it "should allow ranged matches on floats" do
        TheModel.collection(score: "15.0,35.76").length.should == 2
        TheModel.collection(score: "10.0,10.00").length.should == 1
        TheModel.collection(score: "100.0,200.0").length.should == 0
      end
        
    end
  end

end
