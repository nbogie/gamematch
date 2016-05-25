class AddLastCollectionRequestTimeToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :last_collection_request_time, :datetime
  end
end
