# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

RedmineApp::Application.routes.draw do
  match 'projects/:id/ratios/:action', :to => 'ratios#index', :via => [:get]
end
