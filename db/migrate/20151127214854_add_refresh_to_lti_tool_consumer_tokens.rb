class AddRefreshToLtiToolConsumerTokens < ActiveRecord::Migration
  def change
    add_column :lti_tool_consumer_tokens, :refresh_token, :string
    add_column :lti_tool_consumer_tokens, :expires_at, :integer
  end
end
