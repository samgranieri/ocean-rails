
require "aws-sdk"

module DynamoDbModel

  DEFAULT_FIELDS = [
    [:created_at,   :datetime], 
    [:updated_at,   :datetime],
    [:lock_version, :integer, default: 0]
  ]

  class DynamoDbError < StandardError; end

  class NoPrimaryKeyDeclared < DynamoDbError; end
  class UnknownTableStatus < DynamoDbError; end
  class RecordInvalid < DynamoDbError; end
  class RecordNotSaved < DynamoDbError; end


  class Base

    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks
    #include ActiveModel::Dirty          # We don't get this to work. Grrr.
    #include ActiveModel::MassAssignmentSecurity
    #require "active_model/mass_assignment_security.rb"


    # ---------------------------------------------------------
    #
    #  Class variables and methods
    #
    # ---------------------------------------------------------

    class_attribute :dynamo_client, instance_writer: false
    class_attribute :dynamo_table, instance_writer: false

    class_attribute :table_name, instance_writer: false
    class_attribute :table_name_prefix, instance_writer: false
    class_attribute :table_name_suffix, instance_writer: false

    class_attribute :table_hash_key, instance_writer: false
    class_attribute :table_range_key, instance_writer: false

    class_attribute :table_read_capacity_units, instance_writer: false
    class_attribute :table_write_capacity_units, instance_writer: false

    class_attribute :fields, instance_writer: false


    def self.set_table_name(name)
      self.table_name = name
    end

    def self.compute_table_name
      name.pluralize.underscore
    end


    def self.table_full_name
      "#{table_name_prefix}#{table_name}#{table_name_suffix}"
    end


    def self.primary_key(hash_key, range_key=nil)
      self.table_hash_key = hash_key
      self.table_range_key = range_key
      # Find a better place to do the following initialisation:
      set_table_name compute_table_name unless self.table_name
      nil
    end


    def self.read_capacity_units(units)
      self.table_read_capacity_units = units
    end

    def self.write_capacity_units(units)
      self.table_write_capacity_units = units
    end


    def self.field(name, type=:string, **pairs)
      attr_accessor name
      fields[name] = {type:    type, 
                      default: pairs[:default]}
    end


    def self.establish_db_connection
      self.dynamo_client = AWS::DynamoDB.new
      self.dynamo_table = dynamo_client.tables[table_full_name]
      if dynamo_table.exists?
        case dynamo_table.status
        when :active
          set_dynamo_table_keys
          return true
        when :creating
          sleep 1 while dynamo_table.status == :creating
          set_dynamo_table_keys
          return true
        when :deleting
          sleep 1 while dynamo_table.exists?
          return create_table
        else
          raise UnknownTableStatus.new("Unknown DynamoDB table status '#{dynamo_table.status}'")
        end
      end
      create_table
    end


    def self.set_dynamo_table_keys
      dynamo_table.hash_key = [table_hash_key, fields[table_hash_key][:type]]
      dynamo_table.range_key = [table_range_key, fields[table_range_key][:type]] if table_range_key
    end


    def self.create_table
      self.dynamo_table = dynamo_client.tables.create(
        table_full_name, 
        table_read_capacity_units, 
        table_write_capacity_units,
        hash_key: { table_hash_key => fields[table_hash_key][:type]},
        range_key: table_range_key && { table_range_key => fields[table_range_key][:type]}
        )
      sleep 1 while dynamo_table.status == :creating
      true
    end


    def self.delete_table
      return false unless dynamo_table.exists? && dynamo_table.status == :active
      dynamo_table.delete
      true
    end


    # ---------------------------------------------------------
    #
    #  Callbacks
    #
    # ---------------------------------------------------------

    define_model_callbacks :initialize, only: :after
    define_model_callbacks :save
    define_model_callbacks :create
    define_model_callbacks :update
    define_model_callbacks :destroy



    # ---------------------------------------------------------
    #
    #  Class initialisation, done once at load time
    #
    # ---------------------------------------------------------

    self.table_read_capacity_units = 10
    self.table_write_capacity_units = 5

    self.fields = HashWithIndifferentAccess.new
    DEFAULT_FIELDS.each { |k, name, **pairs| Base.field k, name, **pairs }


    # ---------------------------------------------------------
    #
    #  Instance variables and methods
    #
    # ---------------------------------------------------------

    attr_reader :attributes
    attr_reader :destroyed
    attr_reader :new_record
    attr_reader :persisted


    def initialize(attributes={})
      run_callbacks :initialize do
        @attributes = HashWithIndifferentAccess.new
        fields.each do |name, v| 
          default = v[:default]
          default = default.call if default.is_a?(Proc)
          write_attribute(name, default) unless read_attribute(name)
          self.class.class_eval "def #{name}; read_attribute('#{name}'); end"
          self.class.class_eval "def #{name}=(value); write_attribute('#{name}', value); end"
          if fields[name][:type] == :boolean
            self.class.class_eval "def #{name}?; read_attribute('#{name}'); end"
          end
        end
        super
        @destroyed = false
        @new_record = true
        @persisted = false
        raise NoPrimaryKeyDeclared unless table_hash_key
      end
    end


    def read_attribute(name)
      @attributes[name]
    end

    def write_attribute(name, value)
      @attributes[name] = value
    end


    def id
      read_attribute(table_hash_key)
    end

    def id=(value)
      write_attribute(table_hash_key, value)
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


    def destroyed?
      @destroyed
    end

    def new_record?
      @new_record
    end

    def persisted?
      @persisted
    end


    def save
      begin
        create_or_update
      rescue RecordInvalid
        false
      end
    end

    def save!(*)
      create_or_update || raise(RecordNotSaved)
    end

    def create_or_update
      run_callbacks :save do
        result = new_record? ? create : update
        result != false
      end
    end

    def create
      run_callbacks :create do

        true
      end
    end

    def update
      run_callbacks :update do

        true
      end
    end

    def destroy
      run_callbacks :destroy do
        unless new_record?
          # Delete the record here

        end

        @destroyed = true
        freeze
      end
    end
  end


end

