class Game < ActiveRecord::Base
  has_many :ratings
  has_many :rating_players, :through => :ratings, :source => 'player'

  has_many :ownerships
  has_many :owning_players, :through => :ownerships, :source => 'player'

  has_many :play_wishes
  has_many :keen_players, :through => :play_wishes, :source => 'player'

  def self.search(search_term)
    order(:name).where('name LIKE ?', "%#{search_term}%").first(20)
  end

  def bgg_game_url
    return "https://boardgamegeek.com/boardgame/#{bgg_game_id}"
  end
  
  def bgg_game_analysis_url
    return "https://boardgamegeek.com/geekbuddy/analyze/thing/#{bgg_game_id}"
  end

  def self.find_rare_games
    #TODO: do purely in AR or SQL, without passing the half-way list of ids around
    gids = Game.joins(:ownerships).select('id, name, count(*) as c').group(:id).having('c <= 2')
    gids = Game.joins(:play_wishes).select('id, name, count(*) as pw_c').where(:id => gids.map(&:id)).group(:game_id).having('pw_c > 3')
    return Game.find(gids.map(&:id))
  end
  
end
