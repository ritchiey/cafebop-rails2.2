# works with heroku

require "config/environment"

# use SassOnHeroku 
use Rails::Rack::LogTailer
use Rails::Rack::Static
run ActionController::Dispatcher.new