Rails.application.routes.draw do
  get 'admin/tables'


  get 'choose_no_player', to: 'players#choose_no_player', as: 'choose_no_player'

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
  
  get 'rare_games' => 'games#rare_games'

  get 'players/mark_stale/:id', to: 'players#mark_stale', as: 'mark_stale'

  get 'players/link_with_bgg_account/:id/:bgg_username', to: 'players#link_with_bgg_account
  ', as: 'link_with_bgg_account'

  get 'players/:id/choose', to: 'players#choose_player', as: 'choose_player'

  get 'events/:id/workinprogress', to: 'events#workinprogress', as: 'workinprogress'
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

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
