Rails.application.routes.draw do
  get "landing/index"
  get "up" => "rails/health#show", as: :rails_health_check

  # Action Mailbox for incoming HCB and tracking emails
  mount ActionMailbox::Engine => "/rails/action_mailbox"

  # Defines the root path route ("/")
  root "landing#index"

  # OIDC callbacks
  get "auth/hackclub/callback", to: "sessions#hackclub_callback", as: :hackclub_callback

  # Dashboard
  get "dashboard", to: "dashboard#index", as: :dashboard
  delete "logout", to: "sessions#destroy", as: :logout

  # Admin
  namespace :admin do
    resources :users
    resources :hcb_credentials

    root to: "users#index"

    namespace :tools do
      get "console", to: "console#show", as: :console
      post "console/execute", to: "console#execute", as: :console_execute
      get "console/execute", to: redirect("/admin/tools/console")
      get "console/completions", to: "console#completions", as: :console_completions
    end
  end
end
