class ChangeColumnMeetupIdToText < ActiveRecord::Migration
  def change
    change_column(:events, :meetup_event_id, :text)
  end
end
