require 'test_helper'

class RsvpsControllerTest < ActionController::TestCase
  setup do
    @rsvp = rsvps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rsvps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rsvp" do
    assert_difference('Rsvp.count') do
      post :create, rsvp: { meetup_user_id: @rsvp.meetup_user_id, response: @rsvp.response }
    end

    assert_redirected_to rsvp_path(assigns(:rsvp))
  end

  test "should show rsvp" do
    get :show, id: @rsvp
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @rsvp
    assert_response :success
  end

  test "should update rsvp" do
    patch :update, id: @rsvp, rsvp: { meetup_user_id: @rsvp.meetup_user_id, response: @rsvp.response }
    assert_redirected_to rsvp_path(assigns(:rsvp))
  end

  test "should destroy rsvp" do
    assert_difference('Rsvp.count', -1) do
      delete :destroy, id: @rsvp
    end

    assert_redirected_to rsvps_path
  end
end
