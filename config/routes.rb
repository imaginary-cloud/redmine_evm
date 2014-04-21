# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :baselines
resources :projects do 
	resources :baselines
	resources :evms
	get '/baselines/:id/chart_data' => 'evms#chart_data', as: :chart_data
	get '/baselines/:id/versions_chart_data' => 'evms#versions_chart_data', as: :versions_chart_data
	get '/baselines/:id/evm_variables' => 'evms#evm_variables', as: :evm_variables
end
