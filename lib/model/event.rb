class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  embeds_one :geo_location
  belongs_to :user
  index :keywords

  validates_presence_of :text
  validates_presence_of :source
  validates_presence_of :author
  validates_presence_of :date
  
  before_save :set_keywords
  
  field :text, type: String
  field :source, type: String
  field :date, type: DateTime
  field :tags, type: Array, default: []
  field :keywords, type: Array, default: []
  field :author, type: String
  field :version, type: Integer

  def set_keywords
    self.keywords += self.text.scan(/\w+/).collect {|word| word.stem unless @@common_words.member?(word)}
    self.keywords += self.tags.collect {|word| word.stem}
    self.keywords -= [nil]
    self.keywords = self.keywords.uniq
  end
end

class GeoLocation
  include Mongoid::Document
  embedded_in :event

  before_save :calc_geo_hash
  
  def calc_geo_hash
    self.geo_hash = Ultraplex::GeoHash.encode(self.latitude, self.longtitude, self.precision)
  end

  field :precision, type: Integer, default: 10
  field :latitude, type: Float
  field :longtitude, type: Float
  field :geo_hash, type: String
end