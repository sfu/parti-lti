class AddMaxRatingToRooms < ActiveRecord::Migration
  def change
    add_column :rooms, :max_rating, :integer, default: 5
  end
end
