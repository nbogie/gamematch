class AddIndexOnEventIdToRsvps < ActiveRecord::Migration
  def change
    add_index :rsvps, [:event_id, :player_id], unique: true
  end
end
