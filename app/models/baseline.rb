class Baseline < ActiveRecord::Base
	include Redmine::SafeAttributes
  unloadable

  belongs_to :project
  has_and_belongs_to_many :baseline_issues
  has_and_belongs_to_many :baseline_versions

  safe_attributes 'name',
  'description',
  'due_date'


end
