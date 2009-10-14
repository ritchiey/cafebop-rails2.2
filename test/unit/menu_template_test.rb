require 'test_helper'

class MenuTemplateTest < ActiveSupport::TestCase
  should "be valid" do
    assert MenuTemplate.new.valid?
  end
end
