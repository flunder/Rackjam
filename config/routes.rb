Synth4::Application.routes.draw do

  resources :notifications

  resources :alerts

  root :to => "items#index"

  resources :brands
  match 'type/:type'      => "items#index" # /type/mic 
  match 'brand/:brand'    => "items#index" # /brand/akai
  match 'search/:search'  => "items#index" # /search/akai  
    
  resources :skipwords
  resources :items
  resources :interests
  resources :likes
  
  match '/about' => "static#about"  
  match '/hot'   => 'items#top'
  match '/feed'  => 'items#feed',
             :as => :feed,
             :defaults => { :format => 'atom' }
      
  match "get/"             => "items#get"
  match "getone/:url"      => "items#getone"
  match "categorize/:id"   => "items#categorize"
  match "debug/"           => "items#debug"  
  match "runalerts/"       => "alerts#run"
  match "checkalert"       => "alerts#checkalert"    
  match "runnotifications" => "notifications#run"      
  
  devise_for :users, 
             :path_prefix => '',
             :path_names => { :sign_in => "login", :sign_out => "logout", :sign_up => "register" } do
                 get "/login", :to => "devise/sessions#new"
                 get "/users/logout", :to => "devise/sessions#destroy" 
                 get "/register", :to => "devise/registrations#new" 
             end

 

end
