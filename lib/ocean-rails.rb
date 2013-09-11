require "ocean/engine"

require "ocean-dynamo"
require "ocean/api"
require "ocean/api_resource"
require "ocean/ocean_resource_model" if defined? ActiveRecord || defined? OceanDynamo
require "ocean/ocean_resource_controller" if defined? ActionController
require "ocean/ocean_application_controller"
require "ocean/zero_log"
require "ocean/zeromq_logger"
require "ocean/selective_rack_logger"
require "ocean/flooding"



INVALIDATE_MEMBER_DEFAULT =     ["($|/|\\?)"]
INVALIDATE_COLLECTION_DEFAULT = ["($|\\?)"]


module Ocean

  class Railtie < Rails::Railtie
    # Silence the /alive action
    initializer "ocean.swap_logging_middleware" do |app|
      app.middleware.swap Rails::Rack::Logger, SelectiveRackLogger
    end
    # Make sure the generators use the gem's templates first
    config.app_generators do |g|
      g.templates.unshift File::expand_path('../templates', __FILE__)
    end 
  end
  
end


#
# For stubbing successful authorisation calls. Makes <tt>Api.permitted?</tt> return
# the status, and a body containing a partial authentication containing the +user_id+ 
# and +creator_uri+ given by the parameters.
#
def permit_with(status, user_id: 123, creator_uri: "https://api.example.com/v1/api_users/#{user_id}")
  Api.stub(:permitted?).
    and_return(double(:status => status, 
                      :body => {'authentication' => 
                                 {'user_id' => user_id,
                                  '_links' => { 'creator' => {'href' => creator_uri,
                                                              'type' => 'application/json'}}}}))
end

#
# For stubbing failed authorisation calls. Makes <tt>Api.permitted?</tt> return the
# given status and a body containing a standard API error with the given error messages.
#
def deny_with(status, *error_messages)
  Api.stub(:permitted?).
    and_return(double(:status => status, 
                      :body => {'_api_error' => error_messages}))
end
