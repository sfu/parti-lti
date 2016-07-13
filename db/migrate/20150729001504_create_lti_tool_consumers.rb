class CreateLtiToolConsumers < ActiveRecord::Migration
  def change
    create_table :lti_tool_consumers do |t|
      t.string :name
      t.string :oauth_consumer_key
      t.string :oauth_shared_secret
      t.string :product_family
      t.string :url_root
    end
    add_index :lti_tool_consumers, :oauth_consumer_key, unique: true
  end
end
