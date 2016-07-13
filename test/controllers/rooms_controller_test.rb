class RoomsControllerTest < ActionController::TestCase

  test 'index page should require user authentication' do
    get :index
    assert_redirected_to new_user_session_path
  end

  test 'show page should require user authentication' do
    get :show, id: 0
    assert_redirected_to new_user_session_path
  end

  test 'index page should only show rooms matching the filter' do
    tool = create(:lti_tool_consumer)
    other_tool = create(:lti_tool_consumer)

    user = create(:user)
    other_user = create(:user)

    # Set up the room to be filtered by
    filtering_room = create(:room, name: 'FR', lti_tool_consumer: tool, lti_context_type: 'course', lti_context_id: 15)
    Teacher.create(room: filtering_room, user: user)

    # Matching room
    room1 = create(:room, name: 'Correct', lti_tool_consumer: tool, lti_context_type: 'course', lti_context_id: 15)
    Teacher.create(room: room1, user: user)
    # Mismatched room: different context ID
    room2 = create(:room, lti_tool_consumer: tool, lti_context_type: 'course', lti_context_id: 16)
    Teacher.create(room: room2, user: user)
    # Mismatched room: different context type
    room3 = create(:room, lti_tool_consumer: tool, lti_context_type: 'group', lti_context_id: 15)
    Teacher.create(room: room3, user: user)
    # Mismatched room: different tool
    room4 = create(:room, lti_tool_consumer: other_tool, lti_context_type: 'course', lti_context_id: 15)
    Teacher.create(room: room4, user: user)
    # Matching room: different user
    room5 = create(:room, lti_tool_consumer: tool, lti_context_type: 'course', lti_context_id: 15)
    Teacher.create(room: room5, user: other_user)

    sign_in user
    get :index, filtering_room_id: filtering_room
    assert_select 'ul' do
      assert_select 'li', 2
      assert_select 'li a', 'FR'
      assert_select 'li a', 'Correct'
    end
  end

  test 'show page should redirect user to home page if room does not exist' do
    user = create(:user)
    sign_in user
    get :show, id: -1
    assert_redirected_to root_path
  end

  test 'show page should redirect user to home page if he/she is not a participant' do
    room = create(:room)
    sign_in create(:user)
    get :show, id: room.id
    assert_redirected_to root_path
  end

  test 'show page should load for teachers' do
    room = create(:room)
    user = create(:user)
    Teacher.create(room: room, user: user)
    sign_in user
    get :show, id: room.id
    assert_response :success
  end

  test 'show page should redirect students to the new submission page if room is open' do
    room = create(:room, open: true)
    user = create(:user)
    Student.create(room: room, user: user)
    sign_in user
    get :show, id: room.id
    assert_redirected_to new_room_submission_path(room)
  end

  test 'show page should display the closed message to students if room is not open' do
    room = create(:room, open: false)
    user = create(:user)
    Student.create(room: room, user: user)
    sign_in user
    get :show, id: room.id
    assert_select 'p', 'You can not upload image since the room is closed.'
  end

  test 'show page should display room name and open state correctly in the form' do
    room = create(:room, open: true)
    user = create(:user)
    Teacher.create(room: room, user: user)
    sign_in user
    get :show, id: room.id
    assert_select '#room_name[value=?]', room.name
    assert_select '#room_open option[selected="selected"][value="true"]', 1
  end

  test 'update page should update room accordingly and redirect user to the room' do
    room = create(:room, open: true)
    user = create(:user)
    Teacher.create(room: room, user: user)
    sign_in user
    patch :update, id: room.id, room: { name: 'New Name', open: false }
    room = Room.find(room.id)
    assert_equal 'New Name', room.name
    assert_not room.open
    assert_redirected_to room
  end

  test 'import participants page should deny access from students' do
    user = create(:user)
    room = create(:room)
    Student.create(room: room, user: user)
    sign_in user
    get :import_participants, id: room.id
    assert_redirected_to room
  end

  test 'import participants page should redirect user to room if it is not supported' do
    # TODO:
    # Tests related to import participants page and lti_* parameters below can be replaced by this test, which stubs
    # out Room#can_import_participants? and Room#import_participants_error.
    skip('To be implemented')
  end

  test 'import participants page should redirect user to room if the tool consumer is not Canvas' do
    tool_consumer = create(:lti_tool_consumer, product_family: nil)
    user = create(:user)
    room = create(:room, lti_tool_consumer: tool_consumer)
    Teacher.create(room: room, user: user)
    sign_in user
    get :import_participants, id: room.id
    assert_redirected_to room

    tool_consumer = create(:lti_tool_consumer, product_family: 'moodle')
    room = create(:room, lti_tool_consumer: tool_consumer)
    Teacher.create(room: room, user: user)
    get :import_participants, id: room.id
    assert_redirected_to room
  end

  test 'import participants page should redirect user to room if url_root is not defined in the tool consumer' do
    tool_consumer = create(:lti_tool_consumer, url_root: nil)
    user = create(:user)
    room = create(:room, lti_tool_consumer: tool_consumer)
    Teacher.create(room: room, user: user)
    sign_in user
    get :import_participants, id: room.id
    assert_redirected_to room
  end

  test 'import participants page should redirect user to room if lti_resource_link_id is not defined' do
    tool_consumer = create(:lti_tool_consumer)
    user = create(:user)
    room = create(:room, lti_tool_consumer: tool_consumer, lti_resource_link_id: nil)
    Teacher.create(room: room, user: user)
    sign_in user
    get :import_participants, id: room.id
    assert_redirected_to room
  end

  test 'import participants page should redirect user to room if lti_context_type is not "course"' do
    tool_consumer = create(:lti_tool_consumer)
    user = create(:user)
    room = create(:room, lti_tool_consumer: tool_consumer, lti_context_type: nil)
    Teacher.create(room: room, user: user)
    sign_in user
    get :import_participants, id: room.id
    assert_redirected_to room

    room = create(:room, lti_tool_consumer: tool_consumer, lti_context_type: 'group')
    Teacher.create(room: room, user: user)
    get :import_participants, id: room.id
    assert_redirected_to room
  end

  test 'import participants page should redirect user to room if lti_context_id is not defined' do
    tool_consumer = create(:lti_tool_consumer)
    user = create(:user)
    room = create(:room, lti_tool_consumer: tool_consumer, lti_context_id: nil)
    Teacher.create(room: room, user: user)
    sign_in user
    get :import_participants, id: room.id
    assert_redirected_to room
  end

  test 'import participants page should indicate need for access token if unavailable' do
    tool_consumer = create(:lti_tool_consumer)
    user = create(:user)
    room = create(:room, lti_tool_consumer: tool_consumer)
    Teacher.create(room: room, user: user)
    sign_in user
    get :import_participants, id: room.id
    assert_select 'nav h1', 'Access Token Required'
  end

  test 'import participants page should refresh an expired access token' do
    skip('To be implemented')
  end

  test 'import participants page should recognize existing users' do
    skip('To be implemented')
  end

  test 'import participants page should create user if user does not exist' do
    skip('To be implemented')
  end

  test 'import participants page should create participants based on enrollment type' do
    skip('To be implemented')
  end

end
