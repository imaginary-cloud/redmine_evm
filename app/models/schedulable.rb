module Schedulable

  #Returns the Budget at Complete (BAC), the planned value at project completion.
  def planned_value_at_completion
    baseline_issues.sum(:estimated_hours)
  end

  def planned_value_by_week
    @planned_value_by_week ||= calculate_planned_value_by_week
  end

  def calculate_planned_value_by_week
    planned_value_by_week = {}
    (start_date.beginning_of_week..end_date).each do |date|
      planned_value_by_week[date.beginning_of_week] = 0
    end

    baseline_issues.each do |baseline_issue|
      unless baseline_issue.start_date.nil? && baseline_issue.end_date.nil?
        baseline_issue_days = (baseline_issue.start_date..baseline_issue.end_date).to_a
        hoursPerDay = baseline_issue.estimated_hours / baseline_issue_days.size
      end
      baseline_issue_days.each do |day|
        planned_value_by_week[day.beginning_of_week] += hoursPerDay
      end
    end
    planned_value_by_week.each do |key, value|

    end
    planned_value_by_week.each_with_object({}) { |(k, v), h| h[k] = v + (h.values.last||0)  }
  end

  #Returns the actual (current time) planned value.
  def planned_value
    if planned_value_by_week[Date.today.beginning_of_week].nil?
      planned_value_at_completion
    else 
      planned_value_by_week[Date.today.beginning_of_week]
    end
  end
  
end