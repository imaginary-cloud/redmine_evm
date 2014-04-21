class BaselineIssue < ActiveRecord::Base
  unloadable

  belongs_to :baseline
  belongs_to :baseline_version


  def end_date 
    @end_date ||= get_end_date
  end

  def get_end_date
    if baseline_version.nil? 
      due_date || baseline.due_date
    else
  	  due_date || baseline_version.end_date || baseline.due_date
    end
  end
end
