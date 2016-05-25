class Game < ActiveRecord::Base
  has_many :ownerships
  has_many :owning_players, :through => :ownerships, :source => 'player'
end
