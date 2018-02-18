Rails.application.routes.draw do

  if Rails.env =~ /^development$/
    root 'static_pages#home'
    get 'easelj/tutorial', to: 'easelj#tutorial'
    get 'easelj/platformer1', to: 'easelj#platformer1'
    get 'easelj/platformer2', to: 'easelj#platformer2'
    get 'easelj/run', to: 'easelj#run'
    get 'easelj/race', to: 'easelj#race'
    get 'easelj/alien', to: 'easelj#alien'
  else
    root 'easelj#alien'
  end

  get 'easelj/free_alien', to: 'easelj#free_alien'

  get 'login', to: 'station_sessions#new'
  post 'login', to: 'station_sessions#create'
  delete 'logout', to: 'station_sessions#destroy'

  get 'admin/login', to: 'admin_sessions#new'
  post 'admin/login', to: 'admin_sessions#create'
  delete 'admin/logout', to: 'admin_sessions#destroy'


  resources :tickets, except: [:edit, :update, :destroy] do
    member do
      put :pay
    end

    # collection do
    #   get 'query'
    # end
  end

  resources :games, except: [:edit, :update, :destroy] do
    member do
      put 'expose'
      get 'hurry'
      get 'status'
    end

    collection do
      get 'current'
      get 'current_status'
      get 'expose_current'
      get 'hurry_current'
    end
  end

  resources :users, only: [:index, :show], param: :mobile do
    member do
      get 'refresh_pin', constraints: {format: :js}
    end
  end

  resources :stations, except: [:destroy] do
    member do
      get 'refresh_pin', constraints: {format: :js}
    end
  end

  resources :admins, except: [:destroy] do
    member do
      get 'refresh_pin', constraints: {format: :js}
    end
  end

  resource :strategies, only: [:show, :edit, :update]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
