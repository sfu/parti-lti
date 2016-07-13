class CreatePseudonyms < ActiveRecord::Migration
  def change
    create_table :pseudonyms do |t|
      t.string :service
      t.string :identifier
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
