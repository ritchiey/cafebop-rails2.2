require 'test_helper'

class ShopsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "uploading a background image" do  
    image_upload = fixture_file_upload('files/logo.png', 'image/png')
    post "/shops", :name=>"Test Shop", :header_background=>image_upload
  end
end
