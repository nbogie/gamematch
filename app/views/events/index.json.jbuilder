json.array!(@events) do |event|
  json.extract! event, :id, :name, :provided_url, :meetup_id, :status, :event_time
  json.url event_url(event, format: :json)
end
