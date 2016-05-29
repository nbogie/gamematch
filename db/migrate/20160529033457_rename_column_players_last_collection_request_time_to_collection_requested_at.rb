class RenameColumnPlayersLastCollectionRequestTimeToCollectionRequestedAt < ActiveRecord::Migration
  def change
    rename_column :players, :collection_requested_at, :collection_requested_at
  end
end
