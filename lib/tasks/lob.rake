namespace :lob do
  desc "fetch the lob users via http and save them to the db"
  task import_users_to_db: :environment do
    Player.all.each do |p| 
      puts p.bgg_username
    end
  end

end
