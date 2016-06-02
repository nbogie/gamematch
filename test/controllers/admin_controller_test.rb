require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  test "should get tables" do
    get :tables
    assert_response :success
  end

end
