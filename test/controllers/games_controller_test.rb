require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  setup do
    @game = games(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:games)
  end

  test "should search" do
    get :index, :term=> 'star wars'
    assert_response :success
    assert_not_nil assigns(:games)
  end


  test "should show game" do
    get :show, id: @game
    assert_response :success
  end

end
