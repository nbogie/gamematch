class CreateRsvps < ActiveRecord::Migration
  def change
    create_table :rsvps, :id => false do |t|
      t.integer :meetup_user_id
      t.integer :meetup_event_id
      t.text :response
    end

  end
end
