Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "public/home#index"
  
  # 利用者向けの予約フロー
  scope :reserve do
    get 'steps', to: 'reserve/steps#index', as: :reserve_steps
    get 'steps/area', to: 'reserve/steps#area', as: :reserve_steps_area
    get 'steps/branch', to: 'reserve/steps#branch', as: :reserve_steps_branch
    get 'steps/datetime', to: 'reserve/steps#datetime', as: :reserve_steps_datetime
    get 'steps/customer', to: 'reserve/steps#customer', as: :reserve_steps_customer
    post 'steps/next', to: 'reserve/steps#next', as: :reserve_steps_next
    get 'confirm', to: 'reserve/confirm#index', as: :reserve_confirm
    post 'confirm', to: 'reserve/confirm#create', as: :reserve_confirm_create
    get 'complete', to: 'reserve/complete#index', as: :reserve_complete
  end
  
  # 管理者向けの機能
  namespace :admin do
    root 'dashboard#index'
    get 'dashboard', to: 'dashboard#index'
    resources :appointments do
      member do
        patch :approve
        patch :cancel
      end
    end
    resources :prints, only: [:index]
  end
  
  # 開発環境でのみletter_openerをマウント
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
