class LtiToolConsumer < ActiveRecord::Base

  def canvas?
    product_family == 'canvas'
  end

  def oauth2_configured?
    url_root.present? && oauth2_client_id.present? && oauth2_client_secret.present?
  end

  def oauth2_client
    options = { site: url_root, authorize_url: oauth2_auth_request_path, token_url: oauth2_token_request_path }
    OAuth2::Client.new(oauth2_client_id, oauth2_client_secret, options)
  end

end
