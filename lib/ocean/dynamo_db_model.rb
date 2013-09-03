
class DynamoDbModel

  DEFAULT_FIELDS = [
    [:id,           :string], 
    [:created_at,   :datetime], 
    [:updated_at,   :datetime],
    [:lock_version, :integer, default: 0]
  ]


  class Base

    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks
    #include ActiveModel::Dirty          # We don't get this to work. Grrr.
    #include ActiveModel::MassAssignmentSecurity
    #require "active_model/mass_assignment_security.rb"

    # extend ActiveSupport::Concern
    
    # included do
    # end
    
    # module ClassMethods
    # end



    class_attribute :fields
    self.fields = Hash.new

    attr_reader :attributes


    def self.field(name, type=:string, **pairs)
      attr_accessor name
      fields[name] = {type:    type, 
                      default: pairs[:default]}
    end

    DEFAULT_FIELDS.each { |k, name, **pairs| Base.field k, name, **pairs }


    define_model_callbacks :initialize, only: :after


    def initialize(attributes={})
      run_callbacks :initialize do
        @attributes = {}
        fields.each do |name, v| 
          @attributes[name.to_s] ||= v[:default].is_a?(Proc) ? v[:default].call : v[:default]
          self.class.class_eval "def #{name}(); @attributes['#{name}']; end"
          self.class.class_eval "def #{name}=(v); @attributes['#{name}'] = v; end"
        end
        super
      end
    end


    def assign_attributes(values, options = {})
      sanitize_for_mass_assignment(values, options[:as]).each do |k, v|
        send("#{k}=", v)
      end
    end

  end


end

