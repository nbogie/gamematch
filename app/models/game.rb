class Game < ActiveRecord::Base
  has_many :ratings
  has_many :rating_players, :through => :ratings, :source => 'player'

  has_many :ownerships
  has_many :owning_players, :through => :ownerships, :source => 'player'

  has_many :play_wishes
  has_many :keen_players, :through => :play_wishes, :source => 'player'
  
  def self.list_a_page(opts)
    common_select(opts)
  end

  def self.search(opts)
    common_select(opts).
    where('name LIKE ?', "%#{opts[:term]}%")
  end

  #Returns games with play_wishes and ownerships associations counted as
  # pw_count and own_count.
  # TODO: do this with scopes instead - more conventional.
  def self.common_select(opts = {})
    select('games.*, count(distinct play_wishes.player_id) AS pw_count, count(distinct ownerships.player_id) AS own_count').
    joins(:play_wishes).
    joins(:ownerships).
    group('games.id').
    order('games.name').limit(opts[:limit] || 15).offset(opts[:offset] || 0)
  end

  def bgg_game_url
    return "https://boardgamegeek.com/boardgame/#{bgg_game_id}"
  end
  
  def bgg_game_analysis_url
    return "https://boardgamegeek.com/geekbuddy/analyze/thing/#{bgg_game_id}"
  end
  
  def self.owned_uniquely_by(player)
    player.owned_games.where('id in (?)', owned_uniquely.map(&:id))
  end

  def self.uniquely_owned_games
    common_select.having('own_count = 1').unscope(:limit).limit(50)
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
    #TODO: do purely in AR or direct SQL
    max_owners = 2
    min_play_wishes = 4
    gids1 = Game.joins(:play_wishes).select('id, name, count(*) as pw_c').group(:game_id).having('pw_c >= ?', min_play_wishes)
    gids2 = Game.joins(:ownerships).select('id, name, count(*) as c').where(:id => gids1.map(&:id)).group(:id).having('c <= ?', max_owners)
    common_select.where(id: gids2.map(&:id)).unscope(:order).order('pw_count DESC, own_count ASC')
  end

  def self.find_desired_games
    #TODO: do purely in AR or direct SQL
    common_select.unscope(:order).order('pw_count DESC, name')
  end
  
end
