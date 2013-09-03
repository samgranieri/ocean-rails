
class DynamoDbModel

  DEFAULT_FIELDS = {
    id:         :string, 
    created_at: :datetime, 
    updated_at: :datetime
  }


  class Base

    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks
    #include ActiveModel::Dirty          # We don't get this to work. Grrr.


    # extend ActiveSupport::Concern
    
    # included do
    # end
    
    # module ClassMethods
    # end



    class_attribute :fields
    self.fields = Hash.new

    attr_reader :attributes


    def self.field(name, type=:string, default: nil)
      attr_accessor name
      fields[name] = {type:    type, 
                      default: default}
    end

    DEFAULT_FIELDS.each { |k, v| Base.field k, v }


    define_model_callbacks :initialize, only: :after


    def initialize(attributes={})
      run_callbacks :initialize do
        @attributes = {}
        fields.each do |name, v| 
          @attributes[name.to_s] ||= v[:default]
          self.class.class_eval "def #{name}(); @attributes['#{name}']; end"
          self.class.class_eval "def #{name}=(v); @attributes['#{name}'] = v; end"
        end
        super
      end
    end


  end


end

