class BaselineVersion < ActiveRecord::Base
  unloadable

  belongs_to :baselines 
  has_many :baseline_issues

end