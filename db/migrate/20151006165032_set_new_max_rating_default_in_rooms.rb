class SetNewMaxRatingDefaultInRooms < ActiveRecord::Migration
  def up
    change_table :rooms do |t|
      t.change_default :max_rating, 4
    end
  end

  def down
    change_table :rooms do |t|
      t.change_default :max_rating, 5
    end
  end
end
