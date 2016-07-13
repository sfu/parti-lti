require 'test_helper'

class SubmissionsControllerTest < ActionController::TestCase

  test "should get index" do
    user = create(:user)
    room = create(:room)
    Teacher.create(room: room, user: user)
    sign_in user
    get :index, room_id: room
    assert_response :success
  end

  test "should load image uploading page successfully" do
    skip('To be implemented')
  end

  test "should upload image successfully after confirm submission" do
    skip('To be implemented')
  end

  test "should not upload image after cancel submission" do
    skip('To be implemented')
  end

  test "should show image after submission successfully" do
    skip('To be implemented')
  end


end
