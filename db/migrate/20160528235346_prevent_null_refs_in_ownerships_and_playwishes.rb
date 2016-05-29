class PreventNullRefsInOwnershipsAndPlaywishes < ActiveRecord::Migration
  def change
    change_column :ownerships,  :game_id,        :integer, :null=> false
    change_column :play_wishes, :game_id,        :integer, :null=> false
    change_column :ownerships,  :meetup_user_id, :integer, :null=> false
    change_column :play_wishes, :meetup_user_id, :integer, :null=> false
  end
end
