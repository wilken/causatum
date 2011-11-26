require 'sinatra'
require 'json'
require 'mongoid'
Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|file| require file }

Mongoid::configure do |config|
  if ENV["MONGOHQ_URL"]
    uri = URI.parse(ENV['MONGOHQ_URL'])
    config.master = Mongo::Connection.new(uri.host, uri.port).db(uri.path.gsub(/^\//, ''))
    config.master.authenticate(uri.user, uri.password)
  else
    config.master = Mongo::Connection.new.db('causatum')
    config.use_utc =  false
    config.use_activesupport_time_zone = true
  end
end

get '/' do
  headers "Content-type"=> "application/json"
  body params.to_json
end

post '/event' do
  params_map = JSON.parse(params.keys[0])
  if !params_map.has_key?("id")
    e = Event.new
  else
    begin
      e = Event.find(params_map["id"])
    rescue
      e = Event.new
    end
  end
  e.author = params_map["author"]
  e.text = params_map["text"]
  e.source = params_map["source"]
  e.date = time_for(params_map["date"])
  e.tags = (e.tags + ((params_map["tags"]||"").split(',')||[])).uniq
  e.save
  if e.valid?
    a =  {status: "ok"}
  else
    a = {status: "error creating event", errors: e.errors}
  end
  a.to_json
end