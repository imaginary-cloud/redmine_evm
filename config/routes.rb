# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :baselines

resources :projects do
  resources :baselines
end

resources :evms
