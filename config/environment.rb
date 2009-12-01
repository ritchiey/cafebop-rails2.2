# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

APPLICATION_DOMAIN= 'cafebop.com'
SUPPORT_EMAIL = 'support@'+APPLICATION_DOMAIN 
GOOGLE_API_KEY= 'ABQIAAAAuTvlrqlJASuyCXRw3N66QRR5Z0OX2BleViBVP01ZJ4jVRbr9tBT3iT4aMGS1m6ZVZdSU-meSFacRSQ'
# Define session key as a constant
SESSION_KEY = '_ordertest_session'
ENV['RECAPTCHA_PUBLIC_KEY'] = '6LdFsQcAAAAAACX_QQwav_HmW9EyFvhcY3GgjINV'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LdFsQcAAAAAAN2jPSftzNNhWO0uduT-0LymVTP4'


Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"  
  #config.gem 'test-unit', :lib => 'test/unit'
  config.gem "mocha"
  config.gem "thoughtbot-shoulda", :lib => "shoulda"
  config.gem "haml"
  config.gem "hobofields"
  config.gem 'rr'
  config.gem 'notahat-machinist', :lib => 'machinist', :source => "http://gems.github.com"
  config.gem 'sevenwire-forgery', :lib => 'forgery', :source => "http://gems.github.com"
  config.gem 'haml'
  config.gem "authlogic"
  config.gem 'searchlogic'
  config.gem 'raganwald-andand', :lib => 'andand', :source => 'http://gems.github.com'
  config.gem "josevalim-rails-footnotes",  :lib => "rails-footnotes", :source => "http://gems.github.com"
  config.gem 'easy_roles', :source => 'http://gemcutter.org'  
  config.gem 'justinfrench-formtastic', :lib=>'formtastic', :source=>'http://gems.github.com'
  config.gem 'geokit'     
  config.gem "ambethia-recaptcha", :lib => "recaptcha/rails", :source => "http://gems.github.com"
  config.gem "aws-s3", :version => ">= 0.6.2", :lib => "aws/s3"
  
  

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de     
  
  config.action_mailer.default_url_options = { :host => APPLICATION_DOMAIN }
 
  config.action_mailer.delivery_method = :smtp

end


ActionMailer::Base.smtp_settings = {
   :address => "mail.authsmtp.com",
   :port => 2525,
   :domain => "cafebop.com",
   :authentication => :login,
   :user_name => "ac43532",
   :password => "aafz9ungf",
}

# Uncomment the line below if you get one of those pesky
# Object#id deprecated warnings and you want to find it
#Object.send :undef_method, :id


