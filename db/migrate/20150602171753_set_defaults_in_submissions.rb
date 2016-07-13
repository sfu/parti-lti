class SetDefaultsInSubmissions < ActiveRecord::Migration
  def up
    change_table :submissions do |t|
      t.change_default :rating, -1
      t.change_default :featured, false
      t.change_default :flagged, false
    end
  end

  def down
    change_table :submissions do |t|
      t.change_default :rating, nil
      t.change_default :featured, nil
      t.change_default :flagged, nil
    end
  end
end
