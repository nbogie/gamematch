class Event < ActiveRecord::Base

  has_many :rsvps, :foreign_key => 'meetup_event_id'
  has_many :players, :through => :rsvps


  def url
    return "https://www.meetup.com/LondonOnBoard/events/#{meetup_event_id}"
  end

  def self.extract_id_from_meetup_url(u)
    return u.match(/events\/([0-9]+)\//)[1]
  end
  
end
