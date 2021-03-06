require 'rubygems'
require 'bundler/setup'
require 'sqlite3'
require 'bgg'
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

def importAllRSVPsForAllEvents
  Rsvp.delete_all
  Event.all.each do |ev|
    #TODO: page through the rsvps to consume all of them
    rsvps = getRSVPsForEventOnePage(ev.meetup_event_id)
    rsvps.each do |r|
      rsvp = Rsvp.new
      rsvp.event = ev
      rsvp.player = Player.find_by(meetup_user_id: r.member['member_id'])
      if rsvp.player.nil?
        Rails.logger.warn "Found rsvp for an unimported player - meetup_user_id: '#{r.member['member_id']}' - ignoring rsvp."
        next
      end
      rsvp.response = r.response
      ev.rsvps.push(rsvp)
      rsvp.save
    end
  end
end

def getRSVPsForEventOnePage(event_id)
    rsvps = @client.fetch(:rsvps,{:event_id => event_id, 
                                 :rsvp=>'yes', 
                                 :omit=> 'group,member_photo,event,venue', 
                                 :page=>70 
                               })
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

def importAllMembers
  Rails.logger.info "Importer: Importing/updating all members from meetup"
  offset = 0
  while (importPageOfMembers(offset) > 0)
    Rails.logger.info "Importer: DONE PAGE: #{offset}.  Sleeping 5 seconds"
    offset += 1
    sleep(5)
  end
  Rails.logger.info "Importer: Finished"
end

def ms_to_time_or_nil(ms)
  ms.nil? ? nil : Time.at(ms/1000)
end

def importPageOfMembers(offset)
  members = getPageOfMembers(offset)
  members.each do |m|
    bio_raw = m.member["bio"]
    found_bgg_tag = findBGGTagInBio(bio_raw)
    existing_player = Player.find_by meetup_user_id: m.id
    if (existing_player)
      Rails.logger.info "Importer: updating timestamps for player which already exists with meetup_user_id #{m.id}: From API: #{m.inspect}, and from DB - player id: #{existing_player.id}"
      h = {}
      h[:last_visited_meetup_at] = ms_to_time_or_nil(m.visited)
      h[:joined_meetup_at] = ms_to_time_or_nil(m.joined)
      Player.update(existing_player.id, h)
    else
      Rails.logger.info "Importer: importing new user:  #{m.inspect}"
      Player.create(meetup_username: m.name, 
                  bgg_username: found_bgg_tag,
                  bgg_user_id: nil,
                  meetup_user_id: m.id,
                  meetup_bio: bio_raw,
                  meetup_link: m.link,
                  joined_meetup_at: ms_to_time_or_nil(m.joined),
                  last_visited_meetup_at: ms_to_time_or_nil(m.visited))
      Rails.logger.info "Importer: Imported user: #{m.name} #{m.id}"
    end
  end
  return members.size
end

def getPageOfMembers(offset)
  Rails.logger.info "Importer: fetching page of members from meetup group."
  members = @client.fetch(:members,{ :group_id => 274386, 
                                     :fields => "bio",
                                     :omit => "topics,photo",
                                     :page=> 200,
                                     :offset => offset })
  #TODO: filter out inactive members
  return members
end

def importAllEvents(nDays)
  Rsvp.delete_all
  Event.delete_all
  events = getEventsForNextNDays(nDays)
  events.map do |event|
    Rails.logger.debug "importing event: #{event.inspect}"
    Event.create({
      name: event.name, 
      provided_url: event.event["event_url"],
      meetup_event_id: event.event["id"],
      status: event.status,
      event_time: event.time
    })
  end
end

def unescapeSpace(str)
  str.gsub('%20', ' ')
end

def lob_guild_members
  <<~HEREDOC.split /\n/
  2grve
  ALGO
  AdmiralGT
  Anamorphic235
  Andarius
  Bang Potential
  Baron Frog
  Bezman
  Blns75
  CDrust
  CJCalogero
  Chaigirl17
  CrazyCod
  DMStue
  DanV
  Darke
  DicingWithDearth
  Earl_G
  Fabio_
  Fortune
  Gaz72uk
  Gizoku
  Gront
  Haakon Gaarder
  Hornby4523
  Ilikegames
  Interociter
  Jeeman
  JimF
  Johan
  JohnBandettini
  Jugular
  Kester
  Litany_Eu
  Lobotnik
  LondononBoard
  Maiacetus
  Mos Blues
  Mr Shrubber
  MurrayL
  Oslot
  PeterM2158
  Phantomwhale
  Picon
  RacingHippo
  Ravenhoe
  Richard M
  Riotgirl
  Roger_Jay
  Sandman14
  ScarletJester
  Sorp222
  SpooksTheHorse
  Stelio
  Strygalldwir
  StuartF
  SuperSize
  TDaver
  Tekopo
  Temple of Battle
  Toastiness
  Tom Chase
  Tonio_London
  Totality
  Truthsayer
  Tulfa
  Tycho
  Uroshnor
  Waaaaaayne
  White Stone
  Xantiriad
  Xithi
  Yodi
  Zubbus
  agius1520
  amorphous
  angelgabriel
  archivists
  arundle
  baditude
  barnetto
  brattle
  brochd
  bucklen_uk
  bulldozers
  c00ky1970
  caro128
  cesco
  crazylegs
  dekkadekkadekka
  discombob
  dthoreau
  duckworp
  edjw
  eldaec
  enz0
  evilm2twjunkie
  exa1zar2ius3
  fairfaxx
  falsedan
  flyingmerlin
  furriebarry
  garner
  geffizozo
  hairyarsenal
  hampshan
  harris_family
  hughganought
  idolwitch
  ill6
  ionicbox
  jellynut
  jond
  jonpurkis
  kamchatka
  kanito8a
  lauramath
  leverus
  lizbot
  lscrock
  magicoctopus
  man on the lam
  matthoppy
  maxdrawdown
  meeplette
  mlmrk
  mulder82
  nickjanaway
  nosywombat
  outlier
  pawnvsdice
  perfectimperfection
  pie_eater81
  pilgrim152
  pmyteh
  praxis330
  qwertymartin
  ragados
  randomgerbil
  recoil1977
  richiban
  rogull72
  rowangray
  rrreow
  salar
  saua
  smok
  softhook
  spaceinvader
  spoon_platoon
  stereoscopy
  stickinsect
  sweetsweetdoughnuts
  thdizzy
  toblerdrone
  tomhoward87
  tpreece
  veemonroe
  vejrum
  vidalvic
  wetwilly487
  whistleblower
  willynch
  woodnoggin
  yoanadim
  zardon
  zzyzxuk
  HEREDOC
end

def set_bgg_meetup_links
  #TODO: read this from a table or db
  bgg_lob_links = [
      [39340532, "Arthurian", "Jason", true], 
      [41555212, "Aliandra", "Mairi", true],
      [53301632, "Leyton", "Bruce", true],
      [12899354, "Maiacetus", "Pankaj", true],
      [151580452, "stereoscopy", "Errol", true],
      [102496152, "Jeeman", "Jee", false],
      [72083722, "pawnvsdice", "Stuart", false],
      [13695428, "randomgerbil", "Ed", false],
      [8748997, "Bezman", "Behrooz", false],
      [152895592, "CDrust", "Drust", false],
      [182872300,"CJCalogero", "CJ", false],
      [24657712, "Dubbelnisse", "Mats", true],
      [96722032, "nathanroche", "Nathan", true],
      [194247084, "Zeik7", "Rob", true],
      [12743081, "divinentd", "Nils", true],
      [188046567, "pie_eater81", "Oliver", true],
      [13265173, "Stelio", "Stelio", true],
      [12362448, "Mrraow", "Stephen", true],
      [7971953, "Tom Chase", "Tom Chase", false],
      [182712715, "RobRun", "Rob Run", false],
      [113779702, "magicoctopus", "Tomi", true],
      [8203939, "Trusty Sapper", "Tommy", true],
      [7307288, "vejrum", "Soren Vejrum", false],
      [185264724, "jelerak", "Alessandro Mongelli", false],
      [9878336, "bestlem", "Mark Bestley", false],
      [158369332, "vixeast", "Vicki Astbury", false], 
      [187328341, "Szajko", "Krisztian Posch", false],
      [140935202, "OroroPro", "David Dawkins", false],
      [118512942, "RhialtoTheMarvellous", "Simon Dowrick", false],
      [23469191, "nosywombat", "Dean Morris", false],
      [18182381, "2grve", "Pouria", false],
      [6210521, "Sorp222", "Paul Lister", false ],
      [5465745, "outlier", "Paul Agapow", false ],
      [11559453, "crazylegs", "Tom P", false ],
      [13127296, "furriebarry", "Ronan", false ],
      [9797120, "discombob", "russell", false],
      [78659442, "benosteen", "Ben O'Steen", false],
      [13294861, "pilgrim152", "Karl Bunyan", false],
      [185063943,'wilesgeoffrey', 'Geoff Wiles', true],
      [149989062, 'chloroform_tea', 'Roseanna Pendlebury', false],
      [61197802, 'Nicopenny', 'Nicolas Barber', false],
      [94984652, 'Stuartjsk', 'Stuart Jackson', false],
      [195881009, 'rwodzu', 'Rwodzu', false],
      [183575577, 'Iaangus', 'Ian Angus', false],
      [133073032, 'saua', 'Joachim', false],
      [6224143, 'pwatson1974', 'Paul Watson', false],
      [120421272, 'TrevPC', 'Trev Caughie', false],
      [33632622, 'alibimonday', 'Adrian Rice', false],
      [90976022, 'davieedwinarcher', 'Davie Edwin Archer', false],
      [150954892, 'ionicbox', 'Justin Smith', false],
      [45276102, 'clownfeet', 'Daniel Simpson', false],
      [119520962, 'Dr Dave', 'David Kennedy', false],
      [197452034, 'alexbatbee', 'Alex Batterbee', false],
      [190614327, 'Joseph2302', 'Joseph Paul', false],
      [14478379, 'HolyHaddock', 'Mark Harris', false],
      [4083582, 'ScarletJester', 'Sam Hoffman', false],
      [53446682, 'cesco', 'Francesco Gigli', false],
      [6952212, 'manfromtherock', 'Rocky ', false],
      [292835, 'veemonroe', 'Vivienne Raper', false],
      [13438989, 'tomhoward87', 'Tom Howard', false],
      [176609912, 'played', 'Adam Majewski', false],
      [116456332, 'mastergrizli', 'Toms', false],
      [13657557, 'vidalvic', 'Victor Vidal', false],
      [183604807, 'brochd', 'Broch', false],
      [134751142, 'Gemsquem', 'Gem', false],
      [3508486, 'Tycho', 'John M', false],
      [18007451, 'Temple of Battle', 'Jacob Temple', false],
      [168711532, 'moosie101', 'moosie101', false],
      [22707451, 'amorphous', 'Markus', false],
      [157507852, 'freddo123', 'Fred', false],
      [65325912, 'TDaver', 'Dávid Turczi', false],
      [2951675, 'Mr Shrubber', 'Jeroen van den Hark', false],
      [14369774, 'Jugular', 'George Leach', false],
      [7071592, 'softhook', 'Christian Nold', false],
      [48585252, 'Interociter', 'Joe B', false],
      [15740551, 'Roger_Jay', 'Roger (Jay)', false],
      [8107819, 'de_aztec', 'Jason Christie', false],
      [70582182, '6uka', 'Vika', false],
      [82647442, 'StephiH', 'Stephanie H', false],
      [48889852, '210pasadena', 'Mark Chessher', false],
      [85716142, 'hrimalf', 'Rachel Godfrey', false],
      [130076992, 'phvlvt', 'Pieter ver Loren van Themaat', false],
      [26686352, 'hairyarsenal', 'Chris Marling', false],
      [10342108, 'harris_family', 'Simon H', false],
      [19083431, 'Tekopo', 'Riccardo Fabris', false],
      [8671792, 'woodnoggin', 'Rich P', false],
      [29632272, 'getareaction', 'Charlie', false],
      [70296852, 'kendovich', 'Kenneth Petersen', false],
      [120641782, 'RacingHippo', 'John Kennard', false],
      [13331889, 'evilm2twjunkie', 'Tagore', false],
      [100071782, 'Fabio_', 'Fabio Lopiano', false],
      [81570322, 'quilleashm', 'Mike Q', false],
      [12771598, 'Kester', 'Kester', false],
      [10985265, 'JohnBandettini', 'John B', false],
      [206604494, 'Cardboard Conundrum', 'Richie Freeman', false],
      [80788842, 'Granlid', 'Granlid', false],
      [13586732, 'Herzog73', 'Toby', false],
      [21034041, 'Xantiriad', 'Gary Blower', false],
      [82531512, 'klinsy73', 'Chris Keeley', false],
      [185340705, 'Spyros_UCL', 'Spyros', false],
      [8322874, 'malletman', 'Robin Brown', false],
      [12870410, 'Yodi', 'Dan H', false],
      [47631332, 'ncfc', 'Catherine Collins', false],
      [12712378, 'sweetsweetdoughnuts', 'Lloyd', false],
      [70280912, 'GrahamMiller', 'Graham Miller', false],
      [90105582, 'Derek Long', 'Derek Long', false],
      [6926307, 'qwertymartin', 'Martin', false],
    ]
  bgg_lob_links.each do |mid, bgn, real, granted|
    p = Player.find_by meetup_user_id: mid
    p.bgg_username = bgn
    p.granted = granted
    p.save
  end
end

def getOneGuildMembersPage(page)
    #https://boardgamegeek.com/xmlapi2/guild?id=586&members=1&page=2
    g = BggApi.guild(id: 586, members: true, page: page)
    g['members'][0]['member'].map {|h| h['name']} rescue []
end

def get_guild_member_names
  page = 1
  exhausted = false
  all_names = []
  while (!exhausted)
    names = getOneGuildMembersPage(page)
    exhausted = names.empty?
    all_names.push names
    Rails.logger.info "got page #{page} of guild info: #{names}  Sleeping 5 secs..."
    sleep 5
    page = page + 1
  end
  puts "guild member names: "
  all_names.flatten.sort.each do |n|
    puts n
  end
end

def skip(&block)
  puts "skipping block"
end



def importUserGamesFromBGG
  processed_game_ids = []
  players = Player.where("players.bgg_username IS NOT NULL and collection_processed_at IS NULL")
  Rails.logger.info "Processing games for #{players.size} players"
  reqTime = Time.now - 100
  players.each do |player|
    
    bgg_username = unescapeSpace(player.bgg_username)
    Rails.logger.info "processing collection for user: #{bgg_username}"
    
    begin
      #We'd like to request only wanttoplay: 1 OR own: 1 but we can only AND these.
      #Stats are probably a whole lot more data, so 
      #  consider only getting the rated games, with stats, at a second pass.
      while(Time.now < reqTime + 10) do
        remainingTime = reqTime + 10 - Time.now
        Rails.logger.debug("Sleeping #{remainingTime}s to avoid spamming bgg...")
        sleep remainingTime
      end
      
      reqTime = Time.now
      Rails.logger.info("requesting collection for #{bgg_username} at time: #{reqTime}")
      colln = BggApi.collection({username: bgg_username, stats: 1})
    rescue RuntimeError => err
      #TODO: deal also with 503, and other codes.
      if (err.to_s.include?(" 202 "))
        Rails.logger.info "dealing with 202 exception for player: #{bgg_username}"
        player.collection_requested_at = Time.now
        player.save
        next
      else
        raise err
      end
    end

    if (colln.nil? || colln["item"].nil?)
      Rails.logger.warn "No collection for #{bgg_username}: #{colln.inspect}"
      player.collection_processed_at = Time.now
      player.save!
      next
    end

  
    #partitioned = partitionCollection(colln)
    
    #Faster than checking if we already have an ownership record
    Ownership.delete_all(player_id: player.id)
    PlayWish.delete_all(player_id: player.id)
    Rating.delete_all(player_id: player.id)
    colln["item"].each do |g|
      
      gid = g["objectid"]
      gameObj = Game.find_by(bgg_game_id: gid)
      if ((! processed_game_ids.member? gid) &&
           gameObj.nil? )
        Rails.logger.debug "Saving new game to db: #{gid}"
        gameObj = Game.create({ bgg_game_id: gid,
          name: g["name"][0]["content"]
        })
        processed_game_ids.push(g['objectid'])
      else
        #game already exists
      end
      Rails.logger.debug "Game: #{g.inspect}"

      begin
        user_rating_str = g['stats'] ? g['stats'].first['rating'].first['value'] : nil
        user_rating = Float(user_rating_str) rescue nil
        Rails.logger.debug "got user_rating of #{user_rating_str} - parses as #{user_rating}"
        if user_rating
          if (! Rating.exists?(player_id: player.id, game_id: gameObj.id))
              Rails.logger.debug "setting rating"
              Rating.create!({ player_id: player.id, game_id: gameObj.id, rating: user_rating})
          end
        end
      rescue Exception => ex
        Rails.logger.debug("no user rating available: #{ex}")
        user_rating = nil
      end

      if (! PlayWish.exists?(player_id: player.id, game_id: gameObj.id))
        if (g["status"][0]["wanttoplay"] == '1')
          Rails.logger.debug "#{player.meetup_username} wants to play bggid:#{gameObj.bgg_game_id}"
          gameObj.keen_players.push player
          Rails.logger.debug "AFTER"
          Rails.logger.debug "Num play wishes #{gameObj.play_wishes.size} Num ownerships #{gameObj.ownerships.size}"
        end
      end
      
      if (! Ownership.exists?(player_id: player.id, game_id: gameObj.id))
        if (g["status"][0]["own"] == '1')
          Rails.logger.debug "#{player.meetup_username} #{player.id} owns bggid:#{gameObj.bgg_game_id} - pushing"
          gameObj.owning_players.push player
          Rails.logger.debug "Num play wishes #{player.play_wishes.size} Num ownerships #{player.ownerships.size}"
        end
      else
          Rails.logger.debug "#ALREADY OWNED {player.meetup_username} #{player.id} owns bggid:#{gameObj.bgg_game_id} (#{gameObj.id})"
      end
    end #each game in collection
    
    player.collection_processed_at = Time.now
    player.save!
    Rails.logger.debug "Done processing #{colln['item'].size} item(s) for #{player.meetup_username}"

  end #each player
  Rails.logger.info "Done importing games collections for those users"
end #method

def initialize
  api_keys = YAML::load_file('config/api_keys.yaml')
  @client = RMeetup::Client.new(:api_key => api_keys[:meetup_api_key])
end

#SQL to find mutual want-to-play games
#select gu.bgg_username,g.name,gu.own from games_users gu, games g where want_to_play = 1 and g.bgg_game_id = gu.bgg_game_id and gu.bgg_game_id in (select gu.bgg_game_id from games_users gu where gu.want_to_play = 1 group by gu.bgg_game_id having count(*) > 1) order by g.name;

end  #ends class
