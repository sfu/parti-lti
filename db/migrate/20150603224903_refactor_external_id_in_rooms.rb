class RefactorExternalIdInRooms < ActiveRecord::Migration

  EXTERNAL_ID_SEPARATOR = ':::'

  def up
    change_table :rooms do |t|
      t.column :lti_tool_name, :string
      t.column :lti_url_root, :string
      t.column :lti_resource_link_id, :string
      t.column :lti_context_type, :string
      t.column :lti_context_id, :string
      t.index [:lti_tool_name, :lti_resource_link_id]
    end

    # Slot external_id parts into their respective lti_* fields
    Room.transaction do
      Room.all.each do |room|
        parts = room.external_id.split(EXTERNAL_ID_SEPARATOR)
        room.lti_tool_name = parts[0]
        if parts.count <= 2
          room.lti_resource_link_id = parts[1]
        else
          room.lti_url_root = parts[1] if parts[1].present?
          room.lti_resource_link_id = parts[2]
          if parts[3] && parts[3] =~ /^[a-z]+_\d+$/
            room.lti_context_type, room.lti_context_id = parts[3].split('_')
          end
        end
        room.save
      end
    end

    remove_index :rooms, :external_id
    remove_column :rooms, :external_id
  end

  def down
    add_column :rooms, :external_id, :string
    add_index :rooms, :external_id

    # Re-assemble the old external_id from various lti_* fields
    Room.transaction do
      Room.all.each do |room|
        parts = []
        parts << room.lti_tool_name
        parts << room.lti_url_root
        parts << room.lti_resource_link_id
        if room.lti_context_type && room.lti_context_id
          parts << "#{room.lti_context_type}_#{room.lti_context_id}"
        end
        room.external_id = parts.join(EXTERNAL_ID_SEPARATOR)
        room.save
      end
    end

    change_table :rooms do |t|
      t.remove_index column: [:lti_tool_name, :lti_resource_link_id]
      t.remove :lti_tool_name
      t.remove :lti_url_root
      t.remove :lti_resource_link_id
      t.remove :lti_context_type
      t.remove :lti_context_id
    end
  end

end
