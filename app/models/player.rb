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
    Ownership.delete_all(player_id: id)
    PlayWish.delete_all(player_id: id)
    collection_processed_at = nil
    save!
  end

  
  def self.me
    find_by(bgg_username: 'enz0')
  end
  
end
