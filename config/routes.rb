# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :baselines
resources :projects do 
	resources :baselines
  get '/current_baseline', to: 'baselines#current_baseline' 
end
