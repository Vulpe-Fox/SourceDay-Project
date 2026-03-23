Rails.application.routes.draw do
  get "dashboard/index"
  # root "posts#index"
  root "pages#home"
  get "pages/home"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "auth/todoist", to: "oauth#connect", as: :todoist_connect
  get "auth/todoist/callback", to: "oauth#callback"

  # get "dashboard", to: "dashboard#index", as: :dashboard

  post "login/developer_login", to: "sessions#create_developer_session", as: :dev_login
  delete "login/logout", to: "sessions#destroy", as: :logout

  resources :tasks, only: [ :index, :create ]
end
