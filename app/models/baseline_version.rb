class BaselineVersion < ActiveRecord::Base
  include Schedulable
  unloadable

  belongs_to :baseline 
  has_many :baseline_issues
 
  def end_date
    effective_date || baseline.due_date
  end

end