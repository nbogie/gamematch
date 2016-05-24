class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.text :name
      t.integer :game_id

      t.timestamps null: false
    end
    add_index :games, :game_id, unique: true
  end
end
