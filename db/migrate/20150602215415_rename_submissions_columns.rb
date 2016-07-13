class RenameSubmissionsColumns < ActiveRecord::Migration
  def change
    rename_column :submissions, :featured, :show
    add_column :submissions, :starred, :boolean, default: false
  end
end
