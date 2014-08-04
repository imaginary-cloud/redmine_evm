# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :baselines, :except => [:new, :create]
resources :projects do 
	resources :baselines, :only => [:new, :create]
end
