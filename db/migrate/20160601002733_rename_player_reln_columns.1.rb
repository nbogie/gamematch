class RenamePlayerRelnColumns < ActiveRecord::Migration
  def change
    rename_column :ownerships, :meetup_user_id, :player_id
    rename_column :play_wishes, :meetup_user_id, :player_id
  end
end
