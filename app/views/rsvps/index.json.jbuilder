json.array!(@rsvps) do |rsvp|
  json.extract! rsvp, :event_id, :player_id, :response
  json.url rsvp_url(rsvp, format: :json)
end
