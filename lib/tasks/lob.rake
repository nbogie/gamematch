require 'bgg_utils'
require 'rmeetup_utils'

namespace :lob do
  desc "fetch the lob users via http and save them to the db"
  task import_users_to_db: :environment do
    mu = RMeetupUtils.new
    mu.importAllMembersPagedToDB
  end
  
  desc "fetch the upcoming lob meetup events and save them to db"
  task import_events_to_db: :environment do
    mu = RMeetupUtils.new
    Event.delete_all
    mu.importAllEventsToDB(12)
  end

desc "fetch the lob meetup rsvps to the events in db, and save to db"
task import_all_rsvps_for_all_events_to_db: :environment do
  mu = RMeetupUtils.new
  Rsvp.delete_all
  mu.importAllRSVPsForAllEventsToDB
end

desc "add bgg-lob links"
task add_bgg_meetup_links: :environment do
  mu = RMeetupUtils.new
  mu.add_bgg_meetup_links
end

desc "import all users' games from bgg"
task import_user_games_from_BGG: :environment do
  mu = RMeetupUtils.new
  mu.importUserGamesFromBGG
end

end #end lob namespace