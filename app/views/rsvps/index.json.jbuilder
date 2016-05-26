json.array!(@rsvps) do |rsvp|
  json.extract! rsvp, :id, :meetup_user_id, :response
  json.url rsvp_url(rsvp, format: :json)
end
