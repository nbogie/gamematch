class Rsvp < ActiveRecord::Base
  belongs_to :player, :foreign_key => 'meetup_user_id'
  belongs_to :event, :foreign_key => 'meetup_event_id'
end