module Schedulable
  
  #Returns the Budget at Complete (BAC), the planned value at project completion.
  def budget_at_completion 
    if baseline_issues.first.update_hours
      sum_closed_issues = baseline_issues.where(exclude: false, is_closed: true).sum(:spent_hours)
      sum_normal_issues = baseline_issues.where(exclude: false, is_closed: false).sum(:estimated_hours)
      sum_closed_issues+sum_normal_issues
    else
      baseline_issues.where(exclude: false).sum(:estimated_hours)
    end  
  end

  #Returns the planned value distrubeted by weeks
  def planned_value_by_week
    @planned_value_by_week ||= calculate_planned_value_by_week 
  end

  #Returns the actual (today's date) planned value.
  def planned_value
    planned_value_by_week[Date.today].nil? ? budget_at_completion : planned_value_by_week[Date.today]
  end

  private
    
    def calculate_planned_value_by_week
      planned_value_by_week = {}
      (start_date..end_date).each do |date|
        planned_value_by_week[date] = 0
      end
      unless baseline_issues.empty?
        baseline_issues.each do |baseline_issue|
          next if baseline_issue.exclude || baseline_issue.estimated_hours_for_chart == 0 || !baseline_issue.is_leaf
          baseline_issue.days.each do |day|
            planned_value_by_week[day] += baseline_issue.hours_per_day unless planned_value_by_week[day].nil?
          end
        end  
      end
      planned_value_by_week.each_with_object({}) { |(k, v), h| h[k] = v + (h.values.last||0)  }
    end
end