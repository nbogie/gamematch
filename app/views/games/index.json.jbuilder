json.array!(@games) do |game|
  json.extract! game, :id, :name, :bgg_game_id
  json.url game_url(game, format: :json)
end
