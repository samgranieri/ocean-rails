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


  it "should support the after_initialize callback" do
    @i.created_by.should == "Peter"
  end

  it "should support the before_validation callback" do
    @i.destroy_at.should == nil
    @i.valid?
    @i.destroy_at.should be_a Time
  end

  it "should support the after_validation callback" do
    @i.default_step_time.should == 30
    @i.valid?
    @i.default_step_time.should == 60
  end

  it "should support the after_commit callback" do
    @i.started_at.should == nil
    @i.save!
    @i.started_at.should be_a Time
  end

end
