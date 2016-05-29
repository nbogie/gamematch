class ChangeColumnsRsvpsNonNullRefs < ActiveRecord::Migration
  def change
    change_column :rsvps, :meetup_user_id, :integer, :null => false
    change_column :rsvps, :meetup_event_id, :integer, :null => false
  end
end
