class AddLtiToolConsumerIdToRooms < ActiveRecord::Migration
  def change
    add_reference :rooms, :lti_tool_consumer, index: true, foreign_key: true
    remove_index :rooms, column: [:lti_tool_name, :lti_resource_link_id]
  end
end
