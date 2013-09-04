
class DynamoDbModel

  DEFAULT_FIELDS = [
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


    class_attribute :hash_key
    class_attribute :range_key

    def self.primary_key(hash_key, range_key=nil)
      self.hash_key = hash_key
      self.range_key = range_key
    end


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
        @attributes = HashWithIndifferentAccess.new
        fields.each do |name, v| 
          default = v[:default]
          default = default.call if default.is_a?(Proc)
          write_attribute(name, default) unless read_attribute(name)
          self.class.class_eval "def #{name}(); read_attribute('#{name}'); end"
          self.class.class_eval "def #{name}=(value); write_attribute('#{name}', value); end"
        end
        super
      end
    end


    def read_attribute(name)
      @attributes[name]
    end

    def write_attribute(name, value)
      @attributes[name.to_s] = value
    end


    def id
      read_attribute(hash_key)
    end

    def id=(value)
      write_attribute(hash_key, value)
    end


    def to_key
      return nil unless persisted?
      key = respond_to?(:id) && id
      key ? [key] : nil
    end



    def assign_attributes(values)
      values.each do |k, v|
        send("#{k}=", v)
      end
    end

  end


end

