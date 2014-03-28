class Evm 
	include ActiveModel::Model

	def calculate_evm(project) 
		calculate_baseline_pv(project.baselines.last)
		project.baseline_versions.each do |version|
			calculate_version_pv(version)			
		end
	end

	def calculate_baseline_pv(baseline) #calculate the planned value of the given baseline
		end_date = baseline.due_date.strftime('%g').to_i
		start_date = baseline.created_on.strftime('%g').to_i# a start date não pode ser o created on mas sim a started date real
		planned_value = [[0,0]]

		for i in start_date..end_date
			time += calculate_issues_pv(baseline.baseline_issues)
			planned_value.push([time,i])
		end
	end

	def calculate_version_pv(version) #calculate the planned value of the given version
		end_date = version.effective_date.strftime('%g').to_i
		start_date = version.created_on.strftime('%g').to_i
		planned_value = [[0,0]]

		for i in start_date..end_date
			time += calculate_issues_pv(version.baseline_issues)
			planned_value.push([time,i])
		end
	end 

	def calculate_issues_pv(issues) #calculate the planned value of the given issues
		planned_value = 0
		issues.each do |t|
			planned_value+=t.estimated_time
		end
	end 
end