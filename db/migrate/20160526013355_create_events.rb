class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.text :name
      t.text :provided_url
      t.text :meetup_id
      t.text :status
      t.datetime :event_time

      t.timestamps null: false
    end
  end
end
