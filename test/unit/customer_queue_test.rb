require 'test_helper'

class CustomerQueueTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert CustomerQueue.new.valid?
  end
end
