class Game < ActiveRecord::Base
  has_many :ownerships
  has_many :owning_players, :through => :ownerships, :source => 'player'

  has_many :play_wishes
  has_many :keen_players, :through => :play_wishes, :source => 'player'
end
