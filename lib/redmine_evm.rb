Rails.configuration.to_prepare do
  require 'redmine_evm/patches/project_patch'
  require 'redmine_evm/patches/projects_helper_patch'
  require 'redmine_evm/patches/earned_value_patch'
  require 'redmine_evm/patches/actual_cost_patch'
  require 'redmine_evm/patches/chart_dates_patch'
  require 'redmine_evm/patches/data_for_chart_patch'
  require 'redmine_evm/patches/version_patch'
  require 'redmine_evm/patches/issue_patch'
end