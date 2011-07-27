Synth4::Application.routes.draw do

  resources :likes

  root :to => "items#index"

  resources :brands
  resources :skipwords
  resources :items
  
  match '/feed' => 'items#feed',
             :as => :feed,
             :defaults => { :format => 'atom' }
      
  match "get/" => "items#get"
  match "categorize/:id" => "items#categorize"
  
  devise_for :users, 
             :path => '',
             :path_prefix => '',
             :path_names => { :sign_in => "login", :sign_out => "logout", :sign_up => "register" } do
                 get "/login", :to => "devise/sessions#new"
                 get "/logout", :to => "devise/sessions#destroy" 
                 get "/register", :to => "devise/registrations#new" 
             end

end
