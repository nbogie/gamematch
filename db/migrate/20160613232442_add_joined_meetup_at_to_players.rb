class AddJoinedMeetupAtToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :joined_meetup_at, :datetime
  end
end
