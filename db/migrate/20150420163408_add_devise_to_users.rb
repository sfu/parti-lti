class AddDeviseToUsers < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      # NOTE: Other Devise modules not enabled: Recoverable, Rememberable, Trackable, Confirmable, and Lockable.
    end

    add_index :users, :email, unique: true
  end

  def self.down
    remove_index :users, :email

    change_table(:users) do |t|
      t.remove :email, :encrypted_password
    end
  end
end
