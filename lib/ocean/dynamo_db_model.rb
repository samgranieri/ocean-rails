
class DynamoDbModel

  class Base
    include ActiveModel::Model

    extend ActiveSupport::Concern

    included do
    end


    module ClassMethods

    end

    def initialize(attributes={})
      super
    end


  end


end

