
require "aws-sdk"

module Dynamo

  DEFAULT_FIELDS = [
    [:created_at,   :datetime], 
    [:updated_at,   :datetime],
    [:lock_version, :integer, default: 0]
  ]

  class DynamoError < StandardError; end

  class NoPrimaryKeyDeclared < DynamoError; end
  class UnknownTableStatus < DynamoError; end
  class UnsupportedType < DynamoError; end
  class RecordInvalid < DynamoError; end
  class RecordNotSaved < DynamoError; end
  class RecordNotFound < DynamoError; end
  class RecordInConflict < DynamoError; end


  class Base

    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks


    # ---------------------------------------------------------
    #
    #  Class variables and methods
    #
    # ---------------------------------------------------------

    class_attribute :dynamo_client, instance_writer: false
    class_attribute :dynamo_table, instance_writer: false
    class_attribute :dynamo_items, instance_writer: false

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

    def self.set_table_name_prefix(prefix)
      self.table_name_prefix = prefix
    end

    def self.set_table_name_suffix(suffix)
      self.table_name_suffix = suffix
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
      setup_dynamo      
      if dynamo_table.exists?
        wait_until_table_is_active
      else
        create_table
      end
      set_dynamo_table_keys
    end


    def self.setup_dynamo
      #self.dynamo_client = AWS::DynamoDB::Client.new(:api_version => '2012-08-10') 
      self.dynamo_client ||= AWS::DynamoDB.new
      self.dynamo_table = dynamo_client.tables[table_full_name]
      self.dynamo_items = dynamo_table.items
    end


    def self.wait_until_table_is_active
      loop do
        case dynamo_table.status
        when :active
          set_dynamo_table_keys
          return
        when :updating, :creating
          sleep 1
          next
        when :deleting
          sleep 1 while dynamo_table.exists?
          create_table
          return
        else
          raise UnknownTableStatus.new("Unknown DynamoDB table status '#{dynamo_table.status}'")
        end
        sleep 1
      end
    end


    def self.set_dynamo_table_keys
      dynamo_table.hash_key = [table_hash_key, fields[table_hash_key][:type]]
      if table_range_key
        dynamo_table.range_key = [table_range_key, fields[table_range_key][:type]]
      end
    end


    def self.create_table
      self.dynamo_table = dynamo_client.tables.create(table_full_name, 
        table_read_capacity_units, table_write_capacity_units,
        hash_key: { table_hash_key => fields[table_hash_key][:type]},
        range_key: table_range_key && { table_range_key => fields[table_range_key][:type]}
        )
      sleep 1 until dynamo_table.status == :active
      setup_dynamo
      true
    end

    def self.delete_table
      return false unless dynamo_table.exists? && dynamo_table.status == :active
      dynamo_table.delete
      true
    end


    def self.create(attributes = nil, &block)
      object = new(attributes)
      yield(object) if block_given?
      object.save
      object
    end


    def self.create!(attributes = nil, &block)
      object = new(attributes)
      yield(object) if block_given?
      object.save!
      object
    end


    def self.find(hash, range=nil, consistent: false)
      item = dynamo_items[hash, range]
      raise RecordNotFound unless item.exists?
      new.send(:post_instantiate, item, consistent)
    end


    def self.delete(hash, range=nil)
      item = dynamo_items[hash, range]
      return false unless item.exists?
      item.delete
      true
    end


    def self.count
      dynamo_table.item_count || -1    # The || -1 is for fake_dynamo specs.
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
    define_model_callbacks :commit, only: :after
    define_model_callbacks :touch


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
    attr_reader :dynamo_item


    def initialize(attributes={})
      run_callbacks :initialize do
        @attributes = HashWithIndifferentAccess.new
        fields.each do |name, v| 
          write_attribute(name, evaluate_default(v[:default])) unless read_attribute(name)
          self.class.class_eval "def #{name}; read_attribute('#{name}'); end"
          self.class.class_eval "def #{name}=(value); write_attribute('#{name}', value); end"
          if fields[name][:type] == :boolean
            self.class.class_eval "def #{name}?; read_attribute('#{name}'); end"
          end
        end
        super
        @dynamo_item = nil
        @destroyed = false
        @new_record = true
        raise NoPrimaryKeyDeclared unless table_hash_key
      end
    end


    def read_attribute(name)
      @attributes[name]
    end


    def write_attribute(name, value)
      @attributes[name] = value
    end


    def [](attribute)
      read_attribute attribute
    end


    def []=(attribute, value)
      write_attribute attribute, value
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


    def serialized_attributes
      result = {}
      fields.each do |attribute, metadata|
        serialized = serialize_attribute(attribute, read_attribute(attribute), metadata)
        result[attribute] = serialized unless serialized == nil
      end
      result
    end


    def serialize_attribute(attribute, value, 
                            metadata=fields[attribute],
                            type: metadata[:type],
                            default: metadata[:default])
      return nil if value == nil
      case type
      when :string
        value == "" ? nil : value
      when :integer
        value
      when :float
        value
      when :boolean
        value ? "true" : "false"
      when :datetime
        value.to_i
      when :serialized
        value.to_json
      else
        raise UnsupportedType.new(type.to_s)
      end
    end


    def deserialized_attributes(consistent_read: false, hash: nil)
      hash ||= dynamo_item.attributes.to_hash(consistent_read: consistent_read)
      result = {}
      fields.each do |attribute, metadata|
        result[attribute] = deserialize_attribute(hash[attribute], metadata)
      end
      result
    end


    def deserialize_attribute(value, metadata, 
                              type: metadata[:type], 
                              default: metadata[:default])
      if value == nil && default != nil && type != :string
        return evaluate_default(default)
      end
      case type
      when :string
        return "" if value == nil
        value
      when :integer
        return nil if value == nil
        value.is_a?(Array) ? value.collect(&:to_i) : value.to_i
      when :float
        return nil if value == nil
        value.is_a?(Array) ? value.collect(&:to_f) : value.to_f
      when :boolean
        case value
        when "true"
          true
        when "false"
          false
        else
          nil
        end
      when :datetime
        return nil if value == nil
        Time.at(value.to_i)
      when :serialized
        return nil if value == nil
        JSON.parse(value)
      else
        raise UnsupportedType.new(type.to_s)
      end
    end


    def destroyed?
      @destroyed
    end


    def new_record?
      @new_record
    end


    def persisted?
      !(new_record? || destroyed?)
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


    def update_attributes(attributes={})
      assign_attributes(attributes)
      save
    end


    def update_attributes!(attributes={})
      assign_attributes(attributes)
      save!
    end


    def create_or_update
      result = new_record? ? create : update
      result != false
    end


    def create
      return false unless valid?(:create)
      run_callbacks :commit do
        run_callbacks :save do
          run_callbacks :create do
            write_attribute(table_hash_key, SecureRandom.uuid) if read_attribute(table_hash_key) == nil
            t = Time.now
            self.created_at ||= t
            self.updated_at ||= t
            dynamo_persist
            true
          end
        end
      end
    end


    def update
      return false unless valid?(:update)
      run_callbacks :commit do
        run_callbacks :save do
          run_callbacks :update do
            self.updated_at = Time.now
            dynamo_persist
            true
          end
        end
      end
    end

    def destroy
      run_callbacks :commit do
        run_callbacks :destroy do
          delete
        end
      end
    end


    def delete
      if persisted?
        @dynamo_item.delete
      end
      @destroyed = true
      freeze
    end


    def reload(**keywords)
      range_key = table_range_key && attributes[table_range_key]
      new_instance = self.class.find(id, range_key, **keywords)
      assign_attributes(new_instance.attributes)
      self
    end


    def touch(name=nil)
      run_callbacks :touch do
        attrs = [:updated_at]
        attrs << name if name
        t = Time.now
        attrs.each { |k| write_attribute name, t }
        # TODO: handle lock_version
        dynamo_item.attributes.update do |u|
          attrs.each do |k|
            u.set(k => serialize_attribute(k, t))
          end
        end
        self
      end
    end



    protected

    def evaluate_default(v)
      return v.call if v.is_a?(Proc)
      return v.clone if v.is_a?(Array) || v.is_a?(String)   # Instances need their own copy
      v
    end


    def dynamo_persist
      @dynamo_item = dynamo_items.put(serialized_attributes)
      @new_record = false
    end


    def post_instantiate(item, consistent)
      @dynamo_item = item
      @new_record = false
      assign_attributes(deserialized_attributes(
        hash: nil,
        consistent_read: consistent)
      )
      self
    end

  end # Base

end # Dynamo

