require 'rubygems'
require 'bundler/setup'
require 'sqlite3'
require 'bgg'
require 'bgg_utils' #this one is local
require 'yaml'
require 'rmeetup'

GROUP_ID=274386

class RMeetupUtils
  
def getGroup
  results = @client.fetch(:groups,{:group_id => 274386})
  results.each do |result|
    puts result.name
    puts result.members
  end
end

def getRSVPsForEvent(event_id)
    rsvps = @client.fetch(:rsvps,{:event_id => event_id, 
                                 :rsvp=>'yes', 
                                 :omit=> 'group,member_photo,event,venue', 
                                 :page=>70 
                               })
end

def showRSVPsForEvent(event_id)
  rsvps = getRSVPsForEvent(event_id)
  rsvps.each do |rsvp|
    puts "#{rsvp.member['member_id']},#{rsvp.member['name']},#{rsvp.response}"
  end
  rsvps
end

def getMembers(offset)
  members = @client.fetch(:members,{ :group_id => 274386, 
                                     :fields => "bio",
                                     :omit => "topics,photo",
                                     :page=> 200,
                                     :offset => offset })
  #TODO: filter out inactive members
  return members
end

def getEventsForNextNDays(nDays)
  events = @client.fetch(:events,{ :group_id => 274386, 
                                   :status => 'upcoming', 
                                   :time => ",#{nDays}d", 
                                   :omit => "venue,description,group",
                                   :page=>10 })

  return events
end



def findBGGTagIn(str)
  #strs= ["blah bgg:enz0 simplest", "blah bgg:Haakon%20Gardner withSpace"]
  matches = /bgg:([\w%]+)/.match(str)
  matches ? matches[1] : nil
end

def findBGGTagFromURLInBio(str)
  sample_bio = "blah blah \r\n here's my collection: https://boardgamegeek.com/collection/user/enz0%20foozor?rating=9&subtype=boardgame&ff=1 blah blah\nblah"
  matches = /boardgamegeek.com[\w\/]*\/user\/([\w%]+)+/.match(str)
  matches ? matches[1] : nil
end

def findBGGTagInBio(str)
   tagged = findBGGTagIn(str)
   tagged || findBGGTagFromURLInBio(str)
end

def getAndWriteMembersToStdout(n)
  members = getMembers(n)
  members.each do |m|
    bio_raw = m.member["bio"]
    found_bgg_tag = findBGGTagInBio(bio_raw)
    bio = bio_raw.nil? ? "" : bio_raw.gsub(/\n/, "XYNL").gsub(/\r/, "XYCR").gsub(/,/,"XYCM")
    puts """#{m.name}, #{m.id}, #{m.status}, #{found_bgg_tag}, #{bio}""" #, #{m.member}"""
  end
end

def getAndWriteMembersToDB(offset)
  #TODO: process the users as they're loaded - dont load them all into memory first
  members = getMembers(offset)
  members.each do |m|
    bio_raw = m.member["bio"]
    found_bgg_tag = findBGGTagInBio(bio_raw)
    existing_player = Player.find_by meetup_user_id: m.id
    if (existing_player)
      puts "WARNING: skipping player which already exists with meetup_user_id #{m.id}: From API: #{m.inspect}, and from DB: #{existing_player.inspect}"
    else
      Player.create(meetup_username: m.name, 
                  bgg_username: found_bgg_tag,
                  bgg_user_id: nil,
                  meetup_user_id: m.id,
                  meetup_bio: bio_raw,
                  meetup_status: m.status,
                  meetup_link: m.link,
                  meetup_joined: m.joined)
      puts "Imported user: #{m.name} #{m.id}"
    end
  end
  return members.size
end

def getAllMembersPaged
  0.upto(1) do |n|
    getAndWriteMembers(n)
    sleep(5)
  end
end

def importAllMembersPagedToDB
  offset = 0
  while (getAndWriteMembersToDB(offset) > 0)
    offset += 1
    puts "DONE PAGE: #{offset}"
    sleep(5)
  end
end


def findRSVPsInDB(db, rsvps)
  rsvps.each do |r|
    user_id = r.member['member_id']
    db.execute( "select * from users where meetup_user_id = ?", user_id) do |row|
      p ["selected a user for id ", user_id, row]
    end
    #puts rsvp.member['member_id']},#{rsvp.member['name']},#{rsvp.response}"
  end
end

def showRSVPsForUpcomingEventsInNextNDays(nDays)
  events = getEventsForNextNDays(nDays)
  events.map do |event|
    #{ :id => event.id, :name => event.name, :yes_rsvp_count => event.yes_rsvp_count, :time => event.time}
    puts """EVENT: #{event.event["id"]}, #{event.event["yes_rsvp_count"]}, #{event.name}, #{event.to_h}"""
    puts "RSVPS"
    showRSVPsForEvent(event.event["id"])
  end
end
def findBGGersInDB(db)
  users = []
  db.execute("select bgg_username, bgg_user_id, meetup_username, meetup_user_id from users where bgg_username is not null") do |row|
    p ["selected a user with a bgg username ", row]
    users.push row
  end
  users
end
def unescapeSpace(str)
  str.gsub('%20', ' ')
end

def createUserGames(db)
  rows = db.execute <<-SQL
    create table games_users (
      bgg_username varchar(40),
      game_id varchar(20),
      want_to_play bool,
      own bool
    );
SQL
end

def populateUserGames

  #createUserGames(db)
  processed_game_ids = []
  users = findBGGersInDB(db)
  users.each do |user|
    bgg_username = unescapeSpace(user[0])
    colln = BggApi.collection({username: bgg_username})
    partitioned = partitionCollection(colln)
    strs = colln['item'].map do |g|
      gameInfoAsString(g)
    end

    puts strs.join("\n")
    colln["item"].each do |g|
      db.execute "insert into games_users (bgg_username, game_id, want_to_play, own) values ( ?, ?, ?, ? )", 
                [bgg_username, 
                 g["objectid"], 
                 g["status"][0]["wanttoplay"], 
                 g["status"][0]["own"]]

      if (! processed_game_ids.member? g["objectid"])
        db.execute "insert into games (game_id, name) values ( ?, ? )", 
                [g["objectid"], 
                 g["name"][0]["content"]]
        processed_game_ids.push(g['objectid'])
      end

              #
      #showDetailsOfMyCollection(colln)
    end
  end
end

def initialize
  api_keys = YAML::load_file('config/api_keys.yaml')
  @client = RMeetup::Client.new(:api_key => api_keys[:meetup_api_key])
end

#db = SQLite3::Database.new "bgglob.db"

#getAllMembersPaged

#rsvps = showRSVPsForUpcomingEventsInNextNDays(6)
#rsvps = showRSVPsForEvent("227906557")
#findRSVPsInDB(db, rsvps)

#SQL to find mutual want-to-play games
#select gu.bgg_username,g.name,gu.own from games_users gu, games g where want_to_play = 1 and g.game_id = gu.game_id and gu.game_id in (select gu.game_id from games_users gu where gu.want_to_play = 1 group by gu.game_id having count(*) > 1) order by g.name;

end  #ends class
