class Voom < Dynamo::Base

  set_table_name_suffix Api.basename_suffix

  primary_key :uuid, false

  field :uuid
  field :logged, :serialized, default: []


  def log(str)
    self.logged << str
  end


  after_initialize do
    log "after_initialize"
  end

  before_save do
    log "before_save"
  end

  after_save do
    log "after_save"
  end

  before_create do
    log "before_create"
  end

  after_create do
    log "after_create"
  end
  
  before_update do
    log "before_update"
  end

  after_update do
    log "after_update"
  end
  
  before_validation do
    log "before_validation"
  end

  after_validation do
    log "after_validation"
  end
  
  after_commit do
    log "after_commit"
  end

  before_destroy do
    log "before_destroy"
  end

  after_destroy do
    log "after_destroy"
  end

  before_touch do
    log "before_touch"
  end

  after_touch do
    log "after_touch"
  end


end

