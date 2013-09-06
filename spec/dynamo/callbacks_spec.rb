require 'spec_helper'

describe Voom do

  before :all do
    WebMock.allow_net_connect!
    Voom.establish_db_connection
  end

  before :each do
    @i = Voom.new
  end

  after :all do
    WebMock.disable_net_connect!
  end


  it "should do instantiation callbacks in the correct order" do
    @i.valid?
    @i.logged.should == [
      "after_initialize", 
      "before_validation", 
      "after_validation"
    ]
  end

  it "should do save callbacks in the correct order" do
    @i.save!
    @i.logged.should == [
      "after_initialize", 
      "before_validation", 
      "after_validation", 
      "before_save", 
      "before_create", 
      "after_create", 
      "after_save", 
      "after_commit"
    ]
  end

  it "should do update callbacks in the correct order" do
    @i.save!
    @i.logged = []
    @i.save!
    @i.logged.should == [
      "before_validation", 
      "after_validation", 
      "before_save", 
      "before_update", 
      "after_update", 
      "after_save", 
      "after_commit"
    ]
  end

  it "should do destroy callbacks in the correct order" do
    @i.save!
    @i.logged = []
    @i.destroy
    @i.logged.should == [
      "before_destroy", 
      "after_destroy", 
      "after_commit"
    ]
  end

  # it "should do find callbacks in the correct order" do
  #   @i.save!
  #   @i.logged = []
  #   Voom.find(@i.id, consistent: true).logged.should == [
  #     "after_find", 
  #     "after_initialize", 
  #   ]
  # end


  it "should do touch callbacks in the correct order" do
    @i.save!
    @i.logged = []
    @i.touch
    @i.logged.should == [
      "before_touch", 
      "after_touch"
    ]
  end



end

