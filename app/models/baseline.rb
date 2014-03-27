class Baseline < ActiveRecord::Base
  unloadable

  belongs_to :project
  has_and_belongs_to_many :baseline_issues
  has_and_belongs_to_many :baseline_versions

end
