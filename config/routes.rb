# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :baselines, :except => [:new, :create]
resources :rates, :except => [:new, :create]
resources :projects do 
	resources :baselines, :only => [:new, :create]
	resources :rates, :only => [:new, :create]
end
