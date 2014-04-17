# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html


resources :projects do 
	resources :baselines
	get '/baselines/:id/chart_data' => 'baselines#chart_data', as: :baseline_chart_data
end

resources :baselines

resources :projects do
	resources :evms
end
