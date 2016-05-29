class ChangeColumnsGameNameAndBggGameIdToNonNull < ActiveRecord::Migration
  def change
    change_column :games, :name, :text, :null => false
    change_column :games, :bgg_game_id, :integer, :null => false
  end
end
