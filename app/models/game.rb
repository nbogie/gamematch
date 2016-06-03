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

  def self.desired_games_for_players(ps)
    Game.select('games.id, games.name, games.bgg_game_id, count(play_wishes.game_id) AS pw_count').
    joins(:play_wishes).
    where('play_wishes.player_id' => ps).
    group('games.id').
    order('pw_count DESC, games.name').limit(10)
  end

  def self.desired_games_for_players_owned_by_others(ps, owners)
    Game.select('games.id, games.name, games.bgg_game_id, count(play_wishes.game_id) AS pw_count').
      joins(:play_wishes).
      where( 'play_wishes.player_id' => ps,
             'id' => Ownership.where(player_id: owners).select(:game_id).distinct
           ).
      select(:id, :meetup_username).
      where(play_wishes: { player_id: ps }).
      group('games.id').
      order('pw_count DESC, games.name')
      .limit(10)
  end
  
  def self.desired_games_for_players_owned_by_others_eager_load_keen_players(others, owner)
    #todo: WIP get rid of this and use the above.
    #The problem is eager loading with conditions, in one query.
    others = others.where('id is not ?', owner.id)
    most_desired_ids = 
      PlayWish.select('play_wishes.game_id, count(play_wishes.player_id) AS pw_count').
        where('play_wishes.game_id' => owner.owned_games, 'play_wishes.player_id' => others).
        group('play_wishes.game_id').
        order('pw_count DESC').
        limit(10)
    
    Game.where(id: most_desired_ids.map(&:game_id)).
      includes(:keen_players).
      select(:id, :meetup_username).
      where(play_wishes: { player_id: others })
  end

  def self.find_rare_games
    #TODO: do purely in AR or SQL, without passing the half-way list of ids around
    gids = Game.joins(:ownerships).select('id, name, count(*) as c').group(:id).having('c <= 2')
    gids = Game.joins(:play_wishes).select('id, name, count(*) as pw_c').where(:id => gids.map(&:id)).group(:game_id).having('pw_c > 3')
    return Game.find(gids.map(&:id))
  end
  
end
