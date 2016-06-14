class RemoveColumnMeetupJoinedFromPlayers < ActiveRecord::Migration
  def change
    remove_column :players, :meetup_joined
  end
end
