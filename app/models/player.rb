class Player < ActiveRecord::Base

  #http://guides.rubyonrails.org/association_basics.html#the-has-many-through-association

  has_many :rsvps, :foreign_key => "meetup_user_id"
  has_many :events, :through => :rsvps


  has_many :ownerships, :foreign_key => "meetup_user_id"
  has_many :owned_games, :through => :ownerships, :source => 'game'

  has_many :play_wishes, :foreign_key => "meetup_user_id"
  has_many :want_to_play_games, :through => :play_wishes, :source => 'game'

  def meetup_user_url
    return "https://www.meetup.com/LondonOnBoard/members/#{meetup_user_id}"
  end
  
  def bgg_user_url
    "https://boardgamegeek.com/user/#{bgg_username}"
  end
  
  
  def remove_games
    Ownership.where(meetup_user_id: id).delete_all
    PlayWish.where(meetup_user_id: id).delete_all
    collection_processed_at = nil
    save!
  end
end
