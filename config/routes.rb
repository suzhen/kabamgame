Kabamgame::Application.routes.draw do
  resources :cities

  devise_for :users

  get "/register"=>"players#index"  
  post "/players"=>"players#create"
  delete "/players/:id"=>"players#destroy"

  get "/getfood"=>"cities#get_food"
  get "/getpopulation"=>"cities#get_population"
  get "/getgold"=>"cities#get_gold"

  post "/trainings"=>"cities#join_training"
  
  get "/queryqueuetrain/:id"=>"cities#querytrain_ajax"
  get "/queryarmlist/:id"=>"cities#queryarm_ajax"
  get "/querywarlist/:id"=>"cities#querywar_ajax"

  get "/citiesforuser/:id"=>"players#cities_ajax"

  get "/finishedarm/:armtype/:num/:time/:city"=>"cities#finished_arm"
  get "/canceltrain/:armtype/:num/:time/:city"=>"cities#cancel_arm"

  post "/attackcity"=>"cities#attack_city"
  # The priority is based upon order of creation:

  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'cities#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
