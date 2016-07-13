class AddGradePassbackFields < ActiveRecord::Migration
  def change
    add_column :rooms, :lti_oauth_consumer_key, :string
    add_column :rooms, :grade_passback_url, :string
    add_column :participants, :grade_passback_id, :string
  end
end
