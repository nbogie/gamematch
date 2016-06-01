class AddRatingsImportedAtToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :ratings_imported_at, :timestamp
  end
end
