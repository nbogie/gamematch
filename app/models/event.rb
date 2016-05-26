class Event < ActiveRecord::Base
  
  def url
    return "https://www.meetup.com/LondonOnBoard/events/#{meetup_id}"
  end

end
