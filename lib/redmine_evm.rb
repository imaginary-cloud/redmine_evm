Rails.configuration.to_prepare do
  require 'redmine_evm/patches/project_patch'
  require 'redmine_evm/patches/projects_helper_patch'
  require 'redmine_evm/patches/version_patch'
  require 'redmine_evm/patches/issue_patch'
  require 'redmine_evm/patches/project_version_patch'
  require 'redmine_evm/hooks/views_issues_hook'
end