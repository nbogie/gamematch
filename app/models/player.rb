class Player < ActiveRecord::Base

  #http://guides.rubyonrails.org/association_basics.html#the-has-many-through-association

  has_many :ownerships, :foreign_key => "meetup_user_id"
  has_many :owned_games, :through => :ownerships, :source => 'game'

  has_many :play_wishes, :foreign_key => "meetup_user_id"
  has_many :want_to_play_games, :through => :play_wishes, :source => 'game'

end
