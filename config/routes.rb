# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

match 'projects/:id/ratios/:action', :to => 'ratios#index', :via => [:get]
