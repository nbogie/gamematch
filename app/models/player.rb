class Player < ActiveRecord::Base

  #http://guides.rubyonrails.org/association_basics.html#the-has-many-through-association

  has_many :rsvps
  has_many :events, :through => :rsvps

  has_many :ratings
  has_many :rated_games, :through => :ratings, :source => 'game'

  has_many :ownerships
  has_many :owned_games, :through => :ownerships, :source => 'game'

  has_many :play_wishes
  has_many :want_to_play_games, :through => :play_wishes, :source => 'game'

  def num_owned_games
    self['own_count'].nil? ? owned_games.size : self['own_count']
  end

  def num_want_to_play_games
    self['pw_count'].nil? ? want_to_play_games.size : self['pw_count']
  end
  
  def meetup_user_url
    return "https://www.meetup.com/LondonOnBoard/members/#{meetup_user_id}"
  end
  
  def bgg_user_url
    "https://boardgamegeek.com/user/#{bgg_username}"
  end
  
  def bgg_disparities_url
    "https://boardgamegeek.com/collection/user/#{bgg_username}?rated=1&ff=1&sort=delta&sortdir=desc&columns=title|bggrating|rating&hiddencolumns=delta"
  end
  
  def search_on_bgg_url
    n = CGI.escape meetup_username
    "https://boardgamegeek.com/geeksearch.php?action=search&objecttype=user&q=#{n}&B1=Go"
  end

  def bgg_want_to_plays_url
    "https://boardgamegeek.com/collection/user/#{bgg_username}?wanttoplay=1&subtype=boardgame&ff=1"
  end
  
  def bgg_owned_games_url
    "https://boardgamegeek.com/collection/user/#{bgg_username}?own=1&subtype=boardgame&ff=1"
  end
  
  def bgg_ratings_url
    "https://boardgamegeek.com/collection/user/#{bgg_username}?rated=1&subtype=boardgame&ff=1"
  end
  
  def remove_games
    #TAG:devonly
    Ownership.delete_all(player_id: id)
    PlayWish.delete_all(player_id: id)
    collection_processed_at = nil
    save!
  end

  def manual_link(bgg_name)
    #TAG:devonly
    bgg_username = bgg_name
    searched_at = Time.now
    save!
    link_string
  end
  
  def link_string
    #TAG:devonly
    "[#{meetup_user_id}, '#{bgg_username}', '#{meetup_username}', false],"
  end
  def self.unlinked_but_recently_visited
    Player.where(bgg_username: nil).order(last_visited_meetup_at: :desc).limit(50)
  end
  
  def self.unlinked_but_attending_something
    Player.where("players.bgg_username is NULL and players.searched_at is NULL and players.meetup_username like '% %'").joins(:rsvps).group(:player_id).order(:meetup_username)
  end

  def self.unlinked_but_bio_mentions_bgg
    Player.where("meetup_bio like '%bgg%' AND bgg_username is null")
  end
  
  def self.attending_something
    Player.joins(:rsvps).group(:player_id)
  end
  
  def self.visitedInLastNWeeks(n)
    Player.where('last_visited_meetup_at > ?', n.weeks.ago.beginning_of_day)
  end
  
  def self.active_and_have_collection_at_least(n)
    Player.select('players.id, count(ownerships.game_id) AS own_count').
      where('bgg_username IS NOT null AND last_visited_meetup_at > ?', 6.months.ago.beginning_of_day).
      joins(:ownerships).
      group(:player_id).
      having('own_count >= ?', n)
  end
  
  def self.with_collections_counted
    select('players.*, count(distinct play_wishes.game_id) AS pw_count, count(distinct ownerships.game_id) AS own_count').
    where('bgg_username IS NOT null').
    joins('LEFT OUTER JOIN play_wishes ON play_wishes.player_id = players.id').
    joins('LEFT OUTER JOIN ownerships ON ownerships.player_id = players.id').
    group('players.id')
  end
  
  def self.mark_rough_visited_for_all_who_attend_something
    #TAG:devonly
    Player.attending_something.
    where(last_visited_meetup_at: nil).
    update_all(last_visited_meetup_at: Time.now - 1.weeks)
  end
  
  def self.search(opts)
    Player.order(:meetup_username).
      limit(opts[:limit]).
      offset(opts[:offset]).
      where('meetup_username LIKE ? or bgg_username LIKE ?', "%#{opts[:term]}%", "%#{opts[:term]}%")
  end

  def self.me
    #TAG:devonly
    find_by(bgg_username: 'enz0')
  end
  
end
