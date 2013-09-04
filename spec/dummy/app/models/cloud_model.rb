class CloudModel < DynamoDbModel::Base

  primary_key :uuid, false

  field :uuid,                 :string,      default: lambda { SecureRandom.uuid }
  field :credentials,          :string,      default: ""
  field :token
  field :steps,                :serialized,  default: []
  field :max_seconds_in_queue, :integer,     default: 1.day
  field :default_poison_limit, :integer,     default: 5
  field :default_step_time,    :integer,     default: 30
  field :created_by,           :string
  field :updated_by,           :string
  field :destroy_at,           :datetime
  field :started_at,           :datetime
  field :last_completed_step,  :integer
  field :succeeded,            :boolean,     default: false
  field :failed,               :boolean,     default: false
  field :poison,               :boolean,     default: false
  field :finished_at,          :datetime


  # # Attributes
  # attr_accessible :uuid, :lock_version,
  #                 :steps, :max_seconds_in_queue, :default_poison_limit,
  #                 :credentials, :token, :default_step_time



  # Validations
  validates_presence_of :uuid

  validates_each :steps do |record, attr, value|
    record.errors.add(attr, 'must be an Array') unless value.is_a?(Array)
  end 

  validates :credentials, presence: { message: "must be specified", on: :create }

  validates_each :credentials, on: :create, allow_blank: true do |job, attr, val|
    username, password = Api.decode_credentials val
    job.errors.add(attr, "are malformed") if username.blank? || password.blank?
  end





  # Callbacks
  after_initialize do |j| 
    j.uuid ||= SecureRandom.uuid
  end

  before_validation do |j| 
    j.destroy_at ||= Time.now.utc + j.max_seconds_in_queue
  end

  # after_create do |j|
  #   j.enqueue unless j.steps == []
  # end

  # after_update  { |model| model.ban }
  # after_destroy { |model| model.ban }


end
