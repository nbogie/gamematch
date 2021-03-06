class Event < ActiveRecord::Base

  has_many :rsvps
  has_many :players, :through => :rsvps


  #The field "meetup_event_id" can be either numeric or alphanumeric, and this 
  #may differ from the one used in the url.
  #We save whatever one is given in the id field.
  def url
    return "https://www.meetup.com/LondonOnBoard/events/#{meetup_event_id}"
  end

  def self.busiest_event
    Event.joins(:rsvps).
      select('events.*, count(*) as rsvp_count').
      group(:event_id).
      order('rsvp_count desc').
      limit(1).
      load[0]
  end
  
  def add_all_members
    #TAG:devonly
    Player.where('bgg_username is not null').each do |p|
      if (!players.member? p)
        players.push(p)
      end
    end
  end
  
end
