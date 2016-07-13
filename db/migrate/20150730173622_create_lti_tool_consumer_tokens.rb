class CreateLtiToolConsumerTokens < ActiveRecord::Migration
  def change
    create_table :lti_tool_consumer_tokens do |t|
      t.references :lti_tool_consumer, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.string :token
    end
  end
end
