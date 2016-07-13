class AddOauth2ToLtiToolConsumers < ActiveRecord::Migration
  def change
    add_column :lti_tool_consumers, :oauth2_auth_request_path, :string
    add_column :lti_tool_consumers, :oauth2_token_request_path, :string
    add_column :lti_tool_consumers, :oauth2_client_id, :string
    add_column :lti_tool_consumers, :oauth2_client_secret, :string
  end
end
