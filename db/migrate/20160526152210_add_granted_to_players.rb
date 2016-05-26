class AddGrantedToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :granted, :boolean
  end
end
