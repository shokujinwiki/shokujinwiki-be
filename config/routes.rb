Rails.application.routes.draw do
  resource :registration, only: [ :create ]
  resource :session, only: [ :create, :destroy ]
  resources :passwords, param: :token
  resources :users do
    resources :reviews, only: [ :index ], module: :users
  end
  resources :reviews
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
