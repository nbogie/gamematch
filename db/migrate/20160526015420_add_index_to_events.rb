class AddIndexToEvents < ActiveRecord::Migration
  def change
    add_index :events, :meetup_id, unique: true
  end
end
