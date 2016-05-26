class AddIndexOnMeetupUserIdGameIdToOwnerships < ActiveRecord::Migration
  def change
    add_index :ownerships, [:game_id, :meetup_user_id], unique: true
  end
end
