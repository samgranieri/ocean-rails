require 'spec_helper'

class Bang < Dynamo::Base

  set_table_name_suffix Api.basename_suffix

  primary_key :uuid


  field :uuid
  field :v,    :float,  default: 1.0

end




describe Bang do

  before :all do
    WebMock.allow_net_connect!
    Bang.establish_db_connection
  end

  before :each do
    @i = Bang.new
  end

  after :all do
    WebMock.disable_net_connect!
  end

  it "should be persistable" do
    @i.save!
  end


end

