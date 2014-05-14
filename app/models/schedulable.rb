module Schedulable

  #Returns the Budget at Complete (BAC), the planned value at project completion.
  def planned_value_at_completion
    baseline_issues.sum(:estimated_hours)
  end

  #Returns the planned value by weeks.
  def planned_value_by_week
    planned_value_by_weeks = {}
    time = 0
    (start_date.to_date..end_date.to_date).each do |key|
      time += baseline_issues.select{ |baseline_issue| baseline_issue.end_date == key }.sum(&:estimated_hours)
      planned_value_by_weeks[key.beginning_of_week] = time
    end
    planned_value_by_weeks
  end

  #Returns the actual (current time) planned value.
  def planned_value
    planned_value = 0
    (start_date.to_date..Date.today.beginning_of_week).each do |key|
      planned_value += baseline_issues.select{ |baseline_issue| baseline_issue.end_date == key }.sum(&:estimated_hours)
    end
    planned_value
  end
  
end