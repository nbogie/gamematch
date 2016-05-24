class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.text :bgg_username
      t.text :bgg_user_id
      t.text :meetup_username
      t.integer :meetup_user_id
      t.text :meetup_bio

      t.timestamps null: false
    end
    add_index :players, :meetup_user_id, unique: true
  end
end
