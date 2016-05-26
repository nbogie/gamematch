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
  0.upto(40) do |n|
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

def importAllEventsToDB(nDays)
  events = getEventsForNextNDays(nDays)
  events.map do |event|
    ev = Event.create({
      name: event.name, 
      provided_url: event.event["event_url"],
      meetup_id: event.event["id"],
      status: event.status,
      event_time: event.time
    })
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

def unescapeSpace(str)
  str.gsub('%20', ' ')
end

def add_bgg_meetup_links
  #TODO: read this from a table or db
  bgg_lob_links = [
      [39340532, "Arthurian", "Jason"], 
      [41555212, "Aliandra", "Mairi"],
      [53301632, "Leyton", "Bruce"],
      [12899354, "Maiacetus", "Pankaj"],
      [151580452, "stereoscopy", "Errol"],
      [102496152, "Jeeman", "Jee"],
      [72083722, "pawnvsdice", "Stuart"],
      [13695428, "randomgerbil", "Ed"],
      [8748997, "Bezman", "Behrooz"],
      [152895592, "CDrust", "Drust"],
      [182872300,"CJCalogero", "CJ"],
      [24657712, "Dubbelnisse", "Mats"],
      [96722032, "nathanroche", "Nathan"],
      [194247084, "Zeik7", "Rob"],
      [12743081, "divinentd", "Nils"],
      [188046567, "pie_eater81", "Oliver"],
      [13265173, "Stelio", "Stelio"],
      [12362448, "Mrraow", "Stephen"],
      [113779702, "magicoctopus", "Tomi"],
      [8203939, "Trusty Sapper", "Tommy"],
      ]
  
  bgg_lob_links.each do |mid, bgn, real|
    p = Player.find_by meetup_user_id: mid
    p.bgg_username = bgn
    p.save
  end
end


def skip(&block)
  puts "skipping block"
end

def populateUserGames
  processed_game_ids = []
  players = Player.where("players.bgg_username IS NOT NULL")
  Rails.logger.info "Processing games for #{players.size} players"
  players.each do |player|
    
    bgg_username = unescapeSpace(player.bgg_username)
    Rails.logger.info "processing collection for user: #{bgg_username}"
    
    begin
      colln = BggApi.collection({username: bgg_username})
    rescue RuntimeError => err
      if (err.to_s.include?(" 202 "))
        Rails.logger.info "dealing with 202 exception for player: #{bgg_username}"
        player.last_collection_request_time = Time.now
        player.save
        next
      else
        raise err
      end
    end

    if (colln.nil? || colln["item"].nil?)
      Rails.logger.warn "No collection for #{bgg_username}: #{colln.inspect}"
      next
    end
  
    partitioned = partitionCollection(colln)
    strs = colln['item'].map do |g|
      gameInfoAsString(g)
    end

    
    puts strs.join("\n")
    colln["item"].each do |g|
      
      gid = g["objectid"]
      gameObj = Game.find_by(game_id: gid)
      if ((! processed_game_ids.member? gid) &&
           gameObj.nil? )
        Rails.logger.debug "Saving new game to db: #{gid}"
        g = Game.create({ game_id: gid,
          name: g["name"][0]["content"]
        })
        processed_game_ids.push(g['objectid'])
      else
        #game already exists
      end
      
      if (g["status"][0]["wanttoplay"] == '1')
        Rails.logger.debug "#{player.meetup_username} wants to play #{gameObj.game_id}"
        gameObj.keen_players.push player
      end
      if (g["status"][0]["own"] == '1')
        Rails.logger.debug "#{player.meetup_username} owns #{gameObj.game_id}"
        gameObj.owning_players.push player
      end

      #showDetailsOfMyCollection(colln)
    end
  end
end

def initialize
  api_keys = YAML::load_file('config/api_keys.yaml')
  @client = RMeetup::Client.new(:api_key => api_keys[:meetup_api_key])
end

#getAllMembersPaged

#rsvps = showRSVPsForUpcomingEventsInNextNDays(6)
#rsvps = showRSVPsForEvent("227906557")
#findRSVPsInDB(db, rsvps)

#SQL to find mutual want-to-play games
#select gu.bgg_username,g.name,gu.own from games_users gu, games g where want_to_play = 1 and g.game_id = gu.game_id and gu.game_id in (select gu.game_id from games_users gu where gu.want_to_play = 1 group by gu.game_id having count(*) > 1) order by g.name;

end  #ends class
