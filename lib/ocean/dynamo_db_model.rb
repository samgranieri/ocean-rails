
class DynamoDbModel

  class Base
    include ActiveModel::Model

    extend ActiveSupport::Concern

    included do
    end



    module ClassMethods
    end


    class_attribute :fields
    self.fields = {id:         {type: :string}, 
                   created_at: {type: :datetime}, 
                   updated_at: {type: :datetime}
                  }


    def self.field(name, type=:string)
      self.fields[name] = {type: type}
    end


    def initialize(attributes={})
      super
    end



  end


end

