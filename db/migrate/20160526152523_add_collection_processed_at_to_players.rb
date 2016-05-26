class AddCollectionProcessedAtToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :collection_processed_at, :datetime
  end
end
