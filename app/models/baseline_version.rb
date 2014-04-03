class BaselineVersion < ActiveRecord::Base
  unloadable

  belongs_to :baseline 
  has_many :baseline_issues

end