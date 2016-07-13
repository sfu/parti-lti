require 'test_helper'

class RoomTest < ActiveSupport::TestCase

  test 'import_participants_error should return nil if the LTI is properly configured' do
    tool_consumer = create(:lti_tool_consumer)
    room = create(:room,
                  lti_tool_consumer: tool_consumer,
                  lti_resource_link_id: 'test_resource_id',
                  lti_context_type: 'course',
                  lti_context_id: 123)
    assert_nil room.import_participants_error
  end

  test 'import_participants_error should return error if there is no linked tool consumer' do
    room = create(:room, lti_tool_consumer: nil)
    assert_not_nil room.import_participants_error
  end

  test 'import_participants_error should return error if the tool consumer is not Canvas' do
    tool_consumer = create(:lti_tool_consumer, product_family: nil)
    room = create(:room, lti_tool_consumer: tool_consumer)
    assert_not_nil room.import_participants_error

    tool_consumer = create(:lti_tool_consumer, product_family: 'moodle')
    room = create(:room, lti_tool_consumer: tool_consumer)
    assert_not_nil room.import_participants_error
  end

  test 'import_participants_error should return error if OAuth2 is not fully configured in the tool consumer' do
    # TODO: Stub out LtiToolConsumer#oauth2_configured?

    tool_consumer = create(:lti_tool_consumer, url_root: nil)
    room = create(:room, lti_tool_consumer: tool_consumer)
    assert_not_nil room.import_participants_error

    tool_consumer = create(:lti_tool_consumer, oauth2_client_id: nil)
    room = create(:room, lti_tool_consumer: tool_consumer)
    assert_not_nil room.import_participants_error

    tool_consumer = create(:lti_tool_consumer, oauth2_client_secret: nil)
    room = create(:room, lti_tool_consumer: tool_consumer)
    assert_not_nil room.import_participants_error
  end

  test 'import_participants_error should return error if lti_resource_link_id is not defined' do
    tool_consumer = create(:lti_tool_consumer)
    room = create(:room, lti_tool_consumer: tool_consumer, lti_resource_link_id: nil)
    assert_not_nil room.import_participants_error
  end

  test 'import_participants_error should return error if lti_context_type is not "course"' do
    tool_consumer = create(:lti_tool_consumer)
    room = create(:room, lti_tool_consumer: tool_consumer, lti_context_type: nil)
    assert_not_nil room.import_participants_error

    room = create(:room, lti_tool_consumer: tool_consumer, lti_context_type: 'group')
    assert_not_nil room.import_participants_error
  end

  test 'import_participants_error should return error if lti_context_id is not defined' do
    tool_consumer = create(:lti_tool_consumer)
    room = create(:room, lti_tool_consumer: tool_consumer, lti_context_id: nil)
    assert_not_nil room.import_participants_error
  end

end
