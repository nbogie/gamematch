class RenameRsvpEventReln < ActiveRecord::Migration
  def change
    rename_column :rsvps, :meetup_event_id, :event_id
  end
end
