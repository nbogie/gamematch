require 'rmeetup_utils'

namespace :lob do
  desc "fetch the lob users via http and save them to the db"
  task import_users_to_db: :environment do
    mu = RMeetupUtils.new
    mu.importAllMembers
  end
  
  desc "fetch the upcoming lob meetup events and rsvps to db"
  task import_events_and_rsvps: :environment do
    mu = RMeetupUtils.new
    Rsvp.delete_all
    Event.delete_all
    mu.importAllEvents(12)
    mu.importAllRSVPsForAllEvents
  end

desc "fetch the lob meetup rsvps to the events in db, and save to db"
task import_rsvps_for_saved_events: :environment do
  mu = RMeetupUtils.new
  Rsvp.delete_all
  mu.importAllRSVPsForAllEventsToDB
end

desc "add bgg-lob links"
task set_bgg_meetup_links: :environment do
  mu = RMeetupUtils.new
  mu.set_bgg_meetup_links
end

desc "import all users' games from bgg"
task import_user_games_from_BGG: :environment do
  mu = RMeetupUtils.new
  mu.importUserGamesFromBGG
end

end #end lob namespace