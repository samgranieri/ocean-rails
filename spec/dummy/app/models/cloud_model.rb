class CloudModel < DynamoDbModel::Base

  field :name
  field :weight,     :float
  field :uuid,       :string
  field :destroy_at, :datetime
  field :steps,      :serialized, default: []

  validates_presence_of :name


  # Callbacks
  after_initialize do |j| 
    j.uuid ||= SecureRandom.uuid
  end

  before_validation do |j| 
    j.destroy_at ||= Time.now.utc + 1.day
  end

  # after_create do |j|
  #   j.enqueue unless j.steps == []
  # end

  # after_update  { |model| model.ban }
  # after_destroy { |model| model.ban }


end
