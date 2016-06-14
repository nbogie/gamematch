class RemoveColumnRatingsImportedAtPlayers < ActiveRecord::Migration
  def change
    remove_column :players, :ratings_imported_at
  end
end
