class AddIndexOnMeetupUserIdGameIdToPlayWishes < ActiveRecord::Migration
  def change
    add_index :play_wishes, [:game_id, :meetup_user_id], unique: true
  end
end
