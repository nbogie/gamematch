class RemoveColumnMeetupStatusFromPlayers < ActiveRecord::Migration
  def change
    remove_column :players, :meetup_status
  end
end
