class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.references :game, index: true, foreign_key: true, null: false 
      t.references :player, index: true, foreign_key: true, null: false 
      t.column :rating, :decimal, null: false
      t.timestamps
    end
  end
end
