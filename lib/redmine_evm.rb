Rails.configuration.to_prepare do
  require 'redmine_evm/patches/project_patch'
  require 'redmine_evm/patches/projects_helper_patch'
  require 'redmine_evm/patches/earned_value_patch'
  require 'redmine_evm/patches/actual_cost_patch'
  require 'redmine_evm/patches/chart_dates_patch'

end