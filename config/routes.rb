Rails.application.routes.draw do
  get "pages/home"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  root "pages#home"

  get "auth/todoist", to: "oauth#connect", as: :todoist_connect
  get "auth/todoist/callback", to: "oauth#callback"

  get "dashboard", to: "dashboard#index", as: :dashboard
end
