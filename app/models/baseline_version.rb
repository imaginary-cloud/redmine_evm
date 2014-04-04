class BaselineVersion < ActiveRecord::Base
  unloadable

  belongs_to :baseline 
  has_many :baseline_issues

  # Returns PV from version.
  def planned_value
    baseline_issues.sum(:estimated_time)
  end

end