class AddSearchedBggToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :searched_at, :datetime
  end
end
