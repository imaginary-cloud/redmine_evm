class BaselineVersion < ActiveRecord::Base
  include Schedulable
  unloadable

  belongs_to :baseline 
  has_many :baseline_issues, dependent: :destroy

  def start_date # start date for chart?
    @start_date ||= baseline_issues.minimum('start_date') #se nao houver start date explode!
  end

  def end_date # end date for chart?
    @end_date = effective_date || baseline.due_date
  end
end

