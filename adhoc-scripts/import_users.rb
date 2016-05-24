require 'rubygems'
require 'bundler/setup'

require 'sqlite3'

puts "started user import to sqlite3"


def findBGGTagIn(str)
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

def createUserCollectionSchema(db)
  rows = db.execute <<-SQL
    create table users_collections (
      bgg_user_id varchar(20),
      collection_text text
    );
SQL
end


def createSchema(db)
  # Create a database
  rows = db.execute <<-SQL
    create table users (
      bgg_username varchar(40),
      bgg_user_id varchar(20),
      meetup_username varchar(40),
      meetup_user_id varchar(20),
      meetup_bio varchar(255)
    );
SQL

  rows = db.execute <<-SQL
    create table games (
      name varchar(200),
      game_id varchar(20)
    );
SQL

  rows = db.execute <<-SQL
    create table games_users (
      bgg_username varchar(40),
      game_id varchar(20),
      want_to_play bool,
      own bool
    );
SQL
end

def demoPopulateGames(db)
  # Execute a few inserts
  {
    "Glory To Rome" => 19857,
    "Race for the Galaxy" => 28143,
  }.each do |pair|
    db.execute "insert into games values ( ?, ? )", pair
  end
end

def demoPopulateGamesUsers(db)
  db.execute "insert into games_users (bgg_username, game_id, want_to_play, own) values ( ?, ?, ?, ? )", [1, 19857, 1, 0]
end

def addUser(db, bgg_username, bgg_user_id, meetup_username, meetup_user_id)
  # Execute inserts with parameter markers
  db.execute("INSERT INTO users (bgg_username, bgg_user_id, meetup_username, meetup_user_id) 
              VALUES (?, ?, ?, ?)", [bgg_username, bgg_user_id, meetup_username, meetup_user_id])
end

def demoSearch
  # Find a few rows
  db.execute( "select * from games" ) do |row|
    p row
  end
end


def unescapeBio(bio_escaped)
  bio_escaped.gsub(/XYCM/, ",").gsub(/XYCR/, "").gsub(/XYNL/, "\n")
end

def parseLine(line)
  fields = line.split(/,/).map do |c|; c.strip; end
  name, lob_user_id, status, prev_bgg_username, bio_escaped = fields
  bgg_username = findBGGTagInBio(bio_escaped)
  { lob_username: name, 
    lob_user_id: lob_user_id, 
    bgg_username: bgg_username, 
    bio: unescapeBio(bio_escaped)
  }
end


INPUT_FILE="sample_data/sensitive/all_members.txt"
def main
  # Open a database
  db = SQLite3::Database.new "bgglob.db"
  createSchema(db)
  lines = File.readlines(INPUT_FILE)
  puts lines.size
  lines.each do |line|
    puts line
    fields = parseLine(line)
    throw Exception.new("foo") if (fields.nil?)
    # bgg_username, bgg_user_id, meetup_username, meetup_user_id
    addUser(db,
      fields[:bgg_username], 
      0,
      fields[:lob_username], 
      fields[:lob_user_id]
      )
  end
end

#HOW TO FIND ROWS WITH DUPLICATE COLUMN VALUES in sqlite3
# "select meetup_user_id, count(*) c from users group by meetup_user_id having c > 1;"

main
