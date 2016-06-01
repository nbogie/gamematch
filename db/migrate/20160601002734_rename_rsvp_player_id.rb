class RenameRsvpPlayerId < ActiveRecord::Migration
  def change
    rename_column :rsvps, :meetup_user_id, :player_id
  end
end
