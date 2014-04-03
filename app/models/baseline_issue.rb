class BaselineIssue < ActiveRecord::Base
  unloadable

  belongs_to :baseline
  belongs_to :baseline_version

end
