require 'test_helper'

class VoteTest < ActiveSupport::TestCase
  
  should "be able to create a vote" do
    @vote = Vote.create
  end
  
end
