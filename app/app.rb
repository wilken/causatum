require 'sinatra'
require './app/config'

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