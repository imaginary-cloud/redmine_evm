class BaselineVersion < ActiveRecord::Base
  unloadable

  has_and_belongs_to_many :baselines 
  has_many :baseline_issues

end
