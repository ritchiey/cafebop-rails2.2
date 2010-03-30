ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'mocha'
require 'test_help'    
require 'shoulda'
require 'fast_context'
#require 'phocus'   
require "authlogic/test_case" 

require File.expand_path(File.dirname(__FILE__) + "/blueprints")


# Disable transparent delayed_job methods in test mode
module Delayed::MessageSending
  def send_later(method, *args)
    send(method, *args)
  end
end

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...

  def login_as_admin  
    # make_admin.tap {|user| login_as user}
    @admin = User.make_unsaved(:active)
    @admin.stubs(:is_admin?).returns(true)
    controller.stubs(:current_user).returns(@admin)
  end               

  def make_admin
    User.make(:active).tap { |user| user.add_role('cafebop_admin') }   
  end      
  alias_method :admin, :make_admin
  
  def login_as user
    UserSession.create(user)
  end
  
  def logout
    UserSession.find.andand.destroy
  end

  def manager_of(shop)
    User.make(:active).tap {|user| shop.work_contracts.create(:role=>'manager', :user=>user)}
  end
  
  def staff_of(shop)
    User.make(:active).tap {|user| shop.work_contracts.create(:role=>'staff', :user=>user)}
  end

  
end

class ActionController::TestCase
  def setup
    super
    @request.cookies[SESSION_KEY] = "faux session"
    Sham.reset
  end
end

Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = false
end

# Mock out the geocoding
class Geokit::Geocoders::MultiGeocoder
  def self.geocode(address)
    return  Geokit::GeoLoc.new(:lat=>-31.952381, :lng=>115.8688224, :accuracy=>8)
  end
end