json.array!(@players) do |player|
  json.extract! player, :id, :bgg_username, :bgg_user_id, :meetup_username, :meetup_user_id, :meetup_bio
  json.url player_url(player, format: :json)
end
