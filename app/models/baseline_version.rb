class BaselineVersion < ActiveRecord::Base
  unloadable

  belongs_to :baseline 
  has_many :baseline_issues


  def start_date 
    start_date
  end

  def end_date
    effective_date || baseline.due_date
  end

end