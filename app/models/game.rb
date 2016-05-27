class Game < ActiveRecord::Base
  has_many :ownerships
  has_many :owning_players, :through => :ownerships, :source => 'player'

  has_many :play_wishes
  has_many :keen_players, :through => :play_wishes, :source => 'player'

  def self.search(search_term)
    order(:name).where('name LIKE ?', "%#{search_term}%").first(20)
  end

  def bgg_game_url
    return "https://boardgamegeek.com/boardgame/#{game_id}"
  end
  
  def bgg_game_analysis_url
    return "https://boardgamegeek.com/geekbuddy/analyze/thing/#{game_id}"
  end
  
end
