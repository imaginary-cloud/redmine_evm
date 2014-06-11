class BaselineVersion < ActiveRecord::Base
  include Schedulable
  unloadable

  belongs_to :baseline 
  has_many :baseline_issues, dependent: :destroy

  def end_date
    effective_date || baseline.due_date
  end

  def is_excluded
    self.exclude
  end
end

