class BaselineIssue < ActiveRecord::Base
  unloadable

  has_and_belongs_to_many :baselines 
  belongs_to :baseline_versios

end
