class BaselineIssue < ActiveRecord::Base
  unloadable

  belongs_to :baseline
  belongs_to :baseline_version


  def end_date
  	due_date || baseline_version.end_date
  end

end
