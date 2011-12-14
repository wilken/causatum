require 'sinatra'
require 'json'
require 'mongoid'
require 'omniauth-openid'
require 'openid/store/filesystem'

Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|file| require file }

Mongoid::configure do |config|
  if ENV["MONGOHQ_URL"]
    uri = URI.parse(ENV['MONGOHQ_URL'])
    config.master = Mongo::Connection.new(uri.host, uri.port).db(uri.path.gsub(/^\//, ''))
    config.master.authenticate(uri.user, uri.password)
    config.skip_version_check=true
  else
    config.master = Mongo::Connection.new.db('causatum')
    config.use_utc =  false
    config.use_activesupport_time_zone = true
  end
end

#use Rack::Session::Cookie
enable :sessions

use OmniAuth::Builder do  
  provider :openid,  :name => 'google', :store => OpenID::Store::Filesystem.new('./tmp'), :identifier => 'https://www.google.com/accounts/o8/id', :require => 'omniauth-openid'
end

helpers do
  def protected!
    p session["auth"]
     redirect '/auth/google' unless session["auth"]
  end
  
  def authorize(auth)
    session["auth"] = auth
  end
end

post '/auth/:name/callback' do
  authorize("hey")
  redirect '/'
end

get '/auth/logout' do
  session.delete("auth")
  redirect '/'
end

get '/' do
  protected!
  erb :index
end

post '/api/users' do
  params = JSON.parse(request.env["rack.request.form_vars"])
  p params
end

post '/api/login' do
  params = JSON.parse(request.env["rack.request.form_vars"])
  p params
end

get "/api/search" do
=begin
islam and loc:100,200 and mecca
{
  "AND" : {
    "KEYWORD" : "islam",
    "AND" : {
      "LOCATION" : [100,200],
      "KEYWORD" : "mecca"
    }
  }
}
=end
end

post '/api/events' do
  params = JSON.parse(request.env["rack.request.form_vars"])
  if !params.has_key?("id")
    e = Event.new
  else
    begin
      e = Event.find(params["id"])
    rescue
      e = Event.new
    end
  end
  e.author = params["author"]
  e.text = params["text"]
  e.source = params["source"]
  e.date = time_for(params["date"])
  e.tags = (e.tags + ((params["tags"]||"").split(',')||[])).uniq
  if params.has_key?("latitude") && params.has_key?("longtitude")
    e.geo_location = GeoLocation.new(latitude: params.has_key?("latitude"), longtitude: params.has_key?("longtitude"))
  end
  e.save
  if e.valid?
    a =  {status: "ok"}
  else
    a = {status: "error creating event", errors: e.errors}
  end
  a.to_json
end