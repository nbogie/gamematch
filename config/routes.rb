Rails.application.routes.draw do


  get 'demo', to: 'players#demo', as: 'demo'
  get 'choose_no_player', to: 'players#choose_no_player', as: 'choose_no_player'
  
  get '/players/most_owns', to: 'players#most_owns', as: 'most_owns'
  get '/players/most_wants', to: 'players#most_wants', as: 'most_wants'
  get '/players/unlinked_attending', to: 'players#unlinked_attending', as: 'unlinked_but_attending_something'
  get '/players/unlinked_but_bio_mentions_bgg', to: 'players#unlinked_but_bio_mentions_bgg', as: 'unlinked_but_bio_mentions_bgg'
  get '/players/unlinked_but_recently_visited', to: 'players#unlinked_but_recently_visited', as: 'unlinked_but_recently_visited'
  get '/players/:id/who_want_to_play_yours', to: 'players#who_want_to_play_yours', as: 'who_want_to_play_yours'
  

  resources :rsvps
  resources :events
  resources :games
  resources :players
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  #for game search autocomplete
  get 'game_names' => 'games#game_names'
  get 'player_names' => 'players#player_names'
  
  get 'rare_games' => 'games#rare_games'
  get 'desired_games' => 'games#desired_games'
  get 'uniquely_owned_games' => 'games#uniquely_owned_games'

  get 'players/mark_stale/:id', to: 'players#mark_stale', as: 'mark_stale'
  get 'players/mark_searched/:id', to: 'players#mark_searched', as: 'mark_searched'

  get 'players/link_with_bgg_account/:id/:bgg_username', to: 'players#link_with_bgg_account
  ', as: 'link_with_bgg_account'

  get 'players/:id/choose', to: 'players#choose_player', as: 'choose_player'

  get 'events/:id/workinprogress', to: 'events#workinprogress', as: 'workinprogress'

  get 'admin/tables'
  get 'admin/stats'
  get 'admin/misc'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
