require 'test_helper'

class LtiToolConsumerTest < ActiveSupport::TestCase

  test 'oauth2_configured? should return true if all required values are present' do
    tool_consumer = create(:lti_tool_consumer,
                           url_root: 'http://canvas.dev', oauth2_client_id: 'id', oauth2_client_secret: 'secret')
    assert tool_consumer.oauth2_configured?
  end

  test 'oauth2_configured? should return false if url_root is undefined' do
    tool_consumer = create(:lti_tool_consumer, url_root: nil)
    assert_not tool_consumer.oauth2_configured?
  end

  test 'oauth2_configured? should return false if oauth2_client_id is undefined' do
    tool_consumer = create(:lti_tool_consumer, oauth2_client_id: nil)
    assert_not tool_consumer.oauth2_configured?
  end

  test 'oauth2_configured? should return false if oauth2_client_secret is undefined' do
    tool_consumer = create(:lti_tool_consumer, oauth2_client_secret: nil)
    assert_not tool_consumer.oauth2_configured?
  end

end
