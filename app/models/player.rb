class Player < ActiveRecord::Base

  has_many :ownerships, :foreign_key => "meetup_user_id"
  has_many :owned_games, :through => :ownerships, :source => 'game'

end
