class TheModel < ActiveRecord::Base

  ocean_resource_model index: [:name, :created_at, :updated_at, 
                               :created_by, :score], 
                       search: :description,
                       invalidate_member:     INVALIDATE_MEMBER_DEFAULT + [lambda { |m| "foo/bar/baz($|?)" }],
                       invalidate_collection: INVALIDATE_COLLECTION_DEFAULT,
                       ranged: [:created_at, :updated_at, 
                                :created_by, :score]

  attr_accessible :name, :description, :lock_version

  validates :name, length: { minimum: 3 }

end
