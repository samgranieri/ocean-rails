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


  it "find should barf on nonexistent keys" do
    expect { CloudModel.find('some-nonexistent-key') }.to raise_error(DynamoDbModel::RecordNotFound)
  end

  it "find should return an existing CloudModel with a dynamo_item when successful" do
    @i.save!
    found = CloudModel.find(@i.uuid, consistent: true)
    found.should be_a CloudModel
    found.dynamo_item.should be_an AWS::DynamoDB::Item
    found.new_record?.should == false
  end

  it "find should return a CloudModel with initalised attributes" do
    t = Time.now
    @i.started_at = t
    @i.save!
    @i.started_at = nil
    found = CloudModel.find(@i.uuid, consistent: true)
    found.started_at.should_not == nil
  end


  describe "deserialize_attribute" do

    it "for :string should return '' for nil, unless there is a default" do
      @i.deserialize_attribute(nil, {}, type: :string).should == ''
      @i.deserialize_attribute(nil, {}, type: :string, default: "Chelsea").should == 'Chelsea'
    end

    it "for :string should handle single strings" do
      @i.deserialize_attribute("hey", {}, type: :string).should == "hey"
    end

    it "for :string should handle string sets" do
      @i.deserialize_attribute(["one", "two", "three"], {}, type: :string).
        should == ["one", "two", "three"]
    end

    it "for :integer should return nil unless there is a default" do
      @i.deserialize_attribute(nil, {}, type: :integer).should == nil
      @i.deserialize_attribute(nil, {}, type: :integer, default: 25).should == 25
    end

    it "for :integer should handle single integers" do
      @i.deserialize_attribute(BigDecimal.new(1000), {}, type: :integer).should == 1000
    end

    it "for :integer should handle integer sets" do
      @i.deserialize_attribute([BigDecimal.new(1), BigDecimal.new(2), BigDecimal.new(3)], {}, type: :integer).
        should == [1, 2, 3]
    end


    it "for :float should return nil unless there is a default" do
      @i.deserialize_attribute(nil, {}, type: :float).should == nil
      @i.deserialize_attribute(nil, {}, type: :float, default: 3.141592).should == 3.141592
    end

    it "for :float should handle single floats" do
      @i.deserialize_attribute(BigDecimal.new(1000), {}, type: :float).should == 1000.0
    end

    it "for :float should handle float sets" do
      @i.deserialize_attribute([BigDecimal.new("1.1"),BigDecimal.new("2.2"),BigDecimal.new("3.3")], {}, type: :float).
        should == [1.1, 2.2, 3.3]
    end


    it "for :boolean should return nil unless there is a default" do
      @i.deserialize_attribute(nil, {}, type: :boolean).should == nil
      @i.deserialize_attribute(nil, {}, type: :boolean, default: true).should == true
    end

    it "for :boolean should return true or false" do
      @i.deserialize_attribute("true", {}, type: :boolean).should == true
      @i.deserialize_attribute("false", {}, type: :boolean).should == false
    end


    it "for :datetime should return nil unless there is a default" do
      @i.deserialize_attribute(nil, {}, type: :datetime).should == nil
      @i.deserialize_attribute(nil, {}, type: :datetime, default: 1.year.ago).to_i.should == 1.year.ago.to_i
    end

    it "for :datetime should return a Time (or Datetime?)" do
      t = Time.now
      @i.deserialize_attribute(BigDecimal.new(t.to_i), {}, type: :datetime).to_i.should == t.to_i
    end


    it "for :serialized should return nil unless there is a default" do
      @i.deserialize_attribute(nil, {}, type: :serialized).should == nil
      @i.deserialize_attribute(nil, {}, type: :serialized, default: [1, 2, 3]).should == [1, 2, 3]
    end

    it "for :serialized should return a Time (or Datetime?)" do
      t = Time.now
      @i.deserialize_attribute([{a:1, b:"foo"}, 2].to_json, {}, type: :serialized).should == [{"a"=>1, "b"=>"foo"}, 2]
    end


    it "should barf on an unsupported data type" do
      expect { @i.deserialize_attribute(nil, {}, type: :nowai) }.to raise_error(DynamoDbModel::UnsupportedType)
    end
  end

end
