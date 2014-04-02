class BaselineIssue < ActiveRecord::Base
  unloadable

  belongs_to :baselines 
  belongs_to :baseline_version

end
