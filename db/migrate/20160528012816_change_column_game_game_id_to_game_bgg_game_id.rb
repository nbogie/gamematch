class ChangeColumnGameGameIdToGameBggGameId < ActiveRecord::Migration
  def change
    rename_column :games, :game_id, :bgg_game_id
  end
end
