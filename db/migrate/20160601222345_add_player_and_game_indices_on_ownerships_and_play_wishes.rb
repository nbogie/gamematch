class AddPlayerAndGameIndicesOnOwnershipsAndPlayWishes < ActiveRecord::Migration
  def change
    add_index :ownerships, :player_id
    add_index :ownerships, :game_id
    add_index :play_wishes, :player_id
    add_index :play_wishes, :game_id
  end
end
