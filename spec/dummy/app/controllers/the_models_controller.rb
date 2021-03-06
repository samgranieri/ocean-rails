class TheModelsController < ApplicationController

  ocean_resource_controller required_attributes: [:lock_version, :name, :description],
                            no_validation_errors_on: :quux

  respond_to :json
  
  before_action :find_the_model, only: [:show, :update, :destroy, :connect]
  before_action :find_connectee, only: :connect
  before_action :require_conditional, only: :show
    
  
  # GET /v1/the_models
  def index
    expires_in 0, 's-maxage' => 30.minutes
    if stale?(collection_etag(TheModel))
      api_render TheModel.collection(params)
    end
  end


  # GET /v1/the_models/1
  def show
    expires_in 0, 's-maxage' => 30.minutes
    if stale?(@the_model)
      api_render @the_model
    end
  end


  # POST /v1/the_models
  def create
    @the_model = TheModel.new(filtered_params TheModel)
    set_updater(@the_model)
    @the_model.save!
    api_render @the_model, new: true
  end


  # PUT /v1/the_models/1
  def update
    if missing_attributes?
      render_api_error 422, "Missing resource attributes"
      return
    end
    @the_model.assign_attributes(filtered_params TheModel)
    set_updater(@the_model)
    @the_model.save!
    api_render @the_model
  end


  # DELETE /v1/the_models/1
  def destroy
    @the_model.destroy
    render_head_204
  end


  # PUT /v1/the_models/1/connect?href=some_uri
  # NB: This doesn't actually connect anything, it's just here to test
  #     find_connectee. This action always returns just a HEAD.
  def connect
    render_head_204
  end
  
  
  private
     
  def find_the_model
    @the_model = TheModel.find_by_id params[:id]
    return true if @the_model
    render_api_error 404, "TheModel not found"
    false
  end
    
end
