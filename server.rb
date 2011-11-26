require 'sinatra'
require 'json'
require 'mongoid'
Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|file| require file }

Mongoid::configure do |config|
  config.master = Mongo::Connection.new.db('causatum')
  config.use_utc =  false
  config.use_activesupport_time_zone = true
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