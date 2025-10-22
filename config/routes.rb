Rails.application.routes.draw do
  resources :banners
  resources :campaigns
  resources :banner_videos
  resources :targets
  resources :rtb_standards
  resources :documents
  resources :categories
  resources :users
  resources :attachments
  resources :lists

  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'
  get '/signup' => 'users#signup', as: 'signup'
  post '/signup' => 'users#create'
  
  get '/myaccount' => 'users#myaccount'
  patch '/myaccountUpdate' => 'users#myaccountUpdate'
  
  root 'dashboards#home'
  get '/' => 'dashboards#home'
  get 'dashboards/campaigndetail' => 'dashboards#campaigndetail'  
  
  get 'dashboards' => 'dashboards#home'
  get 'dashboards/home' => 'dashboards#home'
  
  get 'reports' => 'reports#home'
  get 'reports/home' => 'reports#home'
  
  get 'getCampaignDates' => 'campaigns#getDates'
  get 'getExchangeAttributes' => 'campaigns#getExchangeAttributes'
  get 'biddersSynchAll' => 'campaigns#biddersSynchAll'
  
  get 'duplicatedoc' => 'documents#duplicate'
  get 'duplicatertb_standard' => 'rtb_standards#duplicate'  
  
  get 'help' => 'help#list'
  get 'help/list' => 'help#list'
  get 'help/open' => 'help#open'
  
  post '/attachments/create' => 'attachments#create'
  
  post "/lists/upload" => "lists#upload"

  # Organization Routes
  resource :organization, only: [:show, :update] do
    get :members, on: :member
    post :add_member, on: :member
    delete :remove_member, on: :member
  end
  
  # Organization switching route (uses ID for switching between organizations)
  post '/organizations/:id/switch', to: 'organizations#switch', as: :switch_organization

  # Subscription & Billing Routes
  resources :subscriptions, only: [:index, :new, :create] do
    collection do
      post :cancel
      get :portal
    end
  end

  # Credits Management
  resources :credits, only: [:index, :create]
  get 'credits/new', to: redirect('/credits')  # Redirect to combined page
  get 'credits/success', to: 'credits#success', as: :credits_success
  get 'credits/cancel', to: 'credits#cancel', as: :credits_cancel

  # Invoices
  resources :invoices, only: [:index]

  # Admin Routes
  namespace :admin do
    resources :credits, only: [:index]
    resources :users, only: [] do
      resources :credits, only: [:new, :create], controller: 'credits'
      get 'credits/transactions', to: 'credits#transactions', as: :credit_transactions
    end
  end

  # Stripe Webhooks
  post '/webhooks/stripe' => 'webhooks#stripe'

 namespace :api, defaults: {format: 'json'} do
     namespace :v1 do
      namespace :report do
        post 'summary'
        get 'summary'
      end
    end
  end  
  
end
