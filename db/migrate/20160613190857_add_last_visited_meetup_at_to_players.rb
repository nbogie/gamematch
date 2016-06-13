class AddLastVisitedMeetupAtToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :last_visited_meetup_at, :datetime
  end
end
