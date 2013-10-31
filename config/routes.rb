PsicoApp::Application.routes.draw do

  get "/therapy_sessions/new_as_therapist", to: 'therapy_sessions#new_as_therapist', as: 'new_therapy_session_as_therapist'
  get "/therapy_sessions/new_as_patient", to: 'therapy_sessions#new_as_patient', as: 'new_therapy_session_as_patient'
  post "/create_therapy_session_as_therapist", to: 'therapy_sessions#create_as_therapist', as: 'create_therapy_session_as_therapist'
  post "/create_therapy_session_as_patient", to: 'therapy_sessions#create_as_patient', as: 'create_therapy_session_as_patient'
  get "/therapy_sessions_as_therapist/:confirmed", to: 'therapy_sessions#index_as_therapist'
  get "/therapy_sessions_as_patient/:confirmed", to: 'therapy_sessions#index_as_patient'
  devise_for :admin_users, ActiveAdmin::Devise.config
  #get '/stories', to: redirect('/posts')
  ActiveAdmin.routes(self)

  match '/users/sign_up', to: 'errors#routing', via: 'get'
  #get '/users/sign_up', :to => 'errors#routing'

  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  root :to => 'home#index'
  # You can have the root of your site routed with "root"


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
