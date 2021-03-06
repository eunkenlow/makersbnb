require './app/data_mapper_setup'

class Property
  include DataMapper::Resource

  property :id, Serial
  property :name, String, required: true
  property :location, String, required: true
  property :price, Integer, required: true
  property :description, Text
  property :availability, Boolean, :default => true
  property :image_path, Text

  belongs_to :user
  has n, :requests
  has n, :days, through: Resource

end
