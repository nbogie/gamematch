class CreateOwnerships < ActiveRecord::Migration
  def change
    create_table :ownerships, :id => false do |t| 
      t.column :game_id, :integer
      t.column :meetup_user_id, :integer 
      t.column :text, :string
      t.timestamps
    end
  end
end
