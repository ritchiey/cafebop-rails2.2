require File.dirname(__FILE__) + '/../test_helper'

class ClaimTest < ActiveSupport::TestCase
  
  context "a claim" do
    
    setup do  
      @claim = Claim.make
    end
    
    should "default to pending" do
      assert @claim.pending?
    end

    
  end
  
end