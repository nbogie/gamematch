require 'bgg_utils'
require 'rmeetup_utils'

namespace :lob do
  desc "fetch the lob users via http and save them to the db"
  task import_users_to_db: :environment do
    mu = RMeetupUtils.new
    mu.importAllMembersPagedToDB
  end

end
