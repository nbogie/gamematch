class Event < ActiveRecord::Base

  has_many :rsvps
  has_many :players, :through => :rsvps


  def url
    return "https://www.meetup.com/LondonOnBoard/events/#{meetup_event_id}"
  end

  #The field "meetup_event_id" can be either numeric or alphanumeric, and this 
  #may differ from the one used in the url.
  #We save whatever one is given in the id field.
end
