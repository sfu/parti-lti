class LtiToolConsumerToken < ActiveRecord::Base

  belongs_to :lti_tool_consumer
  belongs_to :user

  def oauth2_access_token
    options = {refresh_token: refresh_token, expires_at: expires_at}
    OAuth2::AccessToken.new(lti_tool_consumer.oauth2_client, token, options)
  end

  def update_with_access_token(access_token)
    update_attributes(
        token: access_token.token,
        refresh_token: access_token.refresh_token,
        expires_at: access_token.expires_at
    )
  end

end
