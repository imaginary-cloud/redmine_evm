# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :baselines
resources :projects do 
	resources :baselines
	resources :evms
	get '/baselines/:id/chart_data' => 'evms#chart_data', as: :baseline_chart_data
end
