class PlayWish < ActiveRecord::Base
  belongs_to :game
  belongs_to :player, :foreign_key => 'meetup_user_id'
end
