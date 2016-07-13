class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.integer :rating
      t.boolean :featured
      t.boolean :flagged
      t.references :participant, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
