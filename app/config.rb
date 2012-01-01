require 'omniauth-openid'
require 'json'
require 'mongoid'
require 'openid/store/filesystem'

Dir[File.dirname(__FILE__) + '/app/**/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/lib/**/*.rb'].each {|file| require file }

set :views, File.dirname(__FILE__) + "/views"

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

use Rack::Session::Cookie, :key => 'rack.session',
                               :path => '/',
                               :expire_after => 5*60*1000,
                               :secret => 'WEFAQAWRWsFSDFSD'

use OmniAuth::Builder do  
  provider :openid,  :name => 'google', :store => OpenID::Store::Filesystem.new(ENV["CAUSATUM_ENV"] == 'production' ? "/tmp" : "./tmp"), :identifier => 'https://www.google.com/accounts/o8/id', :require => 'omniauth-openid'
end

