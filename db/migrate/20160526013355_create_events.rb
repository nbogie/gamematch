class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.text :meetup_event_id
      t.text :name
      t.text :provided_url
      t.text :status
      t.datetime :event_time

      t.timestamps null: false
    end

    add_index :events, :meetup_event_id, unique: true
  end
end
