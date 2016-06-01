class Event < ActiveRecord::Base

  has_many :rsvps
  has_many :players, :through => :rsvps


  def url
    return "https://www.meetup.com/LondonOnBoard/events/#{meetup_event_id}"
  end

  #The field "meetup_event_id" can be either numeric or alphanumeric, and this 
  #may differ from the one used in the url.
  #We save whatever one is given in the id field.
  
  def add_known_users
    ['Maiacetus', 'enz0', 'jonpurkis', 'stereoscopy', 'NormandyWept', 'CDrust'].each do |username|
      p = Player.find_by_bgg_username username
      if (!players.member? p)
        players.push(p)
      end
    end
  end
  
end
