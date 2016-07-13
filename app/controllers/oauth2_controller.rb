class Oauth2Controller < ApplicationController

  before_action :authenticate_user!

  def callback
    return redirect_to root_path, alert: "Integration error occurred: #{params[:error]}" if params.has_key?(:error)
    begin
      state = JSON.parse(params[:state])
    rescue JSON::ParserError
      return redirect_to root_path, alert: 'Unable to determine the state of the integration request'
    end
    return redirect_to root_path, alert: 'Incomplete integration request' unless state['id'] && state['action']
    tool_consumer = LtiToolConsumer.find_by(id: state['id'])
    return redirect_to root_path, alert: 'Unknown client specified in the integration request' unless tool_consumer

    # Obtain the access token and associate it to the current user
    client = tool_consumer.oauth2_client
    begin
      access_token = client.auth_code.get_token(params[:code], redirect_uri: oauth2_callback_url)
    rescue OAuth2::Error
      return redirect_to root_path, alert: 'Integration error occurred: Unable to obtain access token'
    end
    LtiToolConsumerToken.create(
        user: current_user,
        lti_tool_consumer: tool_consumer,
        token: access_token.token,
        refresh_token: access_token.refresh_token,
        expires_at: access_token.expires_at
    )

    redirect_to state['action']
  end

end
