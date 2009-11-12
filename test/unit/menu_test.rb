require File.dirname(__FILE__) + '/../test_helper'

class MenuTest < ActiveSupport::TestCase

  context "a menu not in a shop" do
    setup do
      @menu = Menu.make(:shop=>nil)
    end

  end
end
