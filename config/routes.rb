Microblog::Application.routes.draw do
  resources :users do
    resources :microposts, :only => [:index, :create, :destroy]
    member do
      get :following, :followers
    end
  end
  
  resources :sessions, :only => [:new, :create, :destroy]
  
  resources :relationships, :only => [:create, :destroy]
  
  match '/signup', :to => 'users#new'
  match '/signin', :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'
  
  root :to => 'pages#home'
end
