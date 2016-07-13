class CreateParticipants < ActiveRecord::Migration
  def change
    create_table :participants do |t|
      t.string :role
      t.references :user, index: true, foreign_key: true
      t.references :room, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
