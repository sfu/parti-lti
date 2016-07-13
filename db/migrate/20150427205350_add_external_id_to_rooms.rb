class AddExternalIdToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :external_id, :string
    add_index :rooms, :external_id
  end
end
