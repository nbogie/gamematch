require 'rubygems'
require 'bundler/setup'

require 'sqlite3'

puts "started sqlite3 test"


# Open a database
db = SQLite3::Database.new "bgglob.db"

# Create a database
rows = db.execute <<-SQL
  create table users (
    bgg_username varchar(40),
    bgg_user_id varchar(20),
    meetup_username varchar(40),
    meetup_user_id varchar(20)
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
    bgg_user_id varchar(20),
    game_id varchar(20),
    want_to_play bool,
    own bool
  );
SQL

# Execute a few inserts
{
  "Glory To Rome" => 19857,
  "Race for the Galaxy" => 28143,
}.each do |pair|
  db.execute "insert into games values ( ?, ? )", pair
end

db.execute "insert into games_users (bgg_user_id, game_id, want_to_play, own) values ( ?, ?, ?, ? )", [1, 19857, 1, 0]

def addUser(db, bgg_username, bgg_user_id, meetup_username, meetup_user_id)
  # Execute inserts with parameter markers
  db.execute("INSERT INTO users (bgg_username, bgg_user_id, meetup_username, meetup_user_id) 
              VALUES (?, ?, ?, ?)", [bgg_username, bgg_user_id, meetup_username, meetup_user_id])
end

# Find a few rows
db.execute( "select * from games" ) do |row|
  p row
end
