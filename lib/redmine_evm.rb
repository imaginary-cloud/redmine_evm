Rails.configuration.to_prepare do
  require 'redmine_evm/patches/project_patch'
  require 'redmine_evm/patches/projects_helper_patch'
  require 'redmine_evm/patches/project_actual_cost_patch'
end