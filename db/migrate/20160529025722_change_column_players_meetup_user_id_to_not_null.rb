class ChangeColumnPlayersMeetupUserIdToNotNull < ActiveRecord::Migration
  def change
    change_column :players, :meetup_user_id, :integer, :null => false
  end
end
