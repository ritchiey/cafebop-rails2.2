# works with heroku

require "config/environment"

if RAILS_ENV == 'production'
  use SassOnHeroku 
end
use Rails::Rack::LogTailer
use Rails::Rack::Static
run ActionController::Dispatcher.new