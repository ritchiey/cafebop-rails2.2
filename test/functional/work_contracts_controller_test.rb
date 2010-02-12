require 'test_helper'

class WorkContractsControllerTest < ActionController::TestCase

  def self.getting_index
    context "getting index" do
      setup do
        get :index
      end

      context "" do
        yield
      end
    end
  end

  
  as_guest do
    getting_index {should_require_login}
  end
  
  
  
end
