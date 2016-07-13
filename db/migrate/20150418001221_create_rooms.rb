class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :name
      t.boolean :open
      t.datetime :start_at
      t.datetime :finish_at

      t.timestamps null: false
    end
  end
end
