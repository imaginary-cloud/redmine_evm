# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html


resources :projects do 
	resources :baselines
end

resources :baselines
resources :evms
