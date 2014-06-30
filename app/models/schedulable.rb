module Schedulable

  #Returns the Budget at Complete (BAC), the planned value at project completion.
  def budget_at_completion 
    #closed(self.id)
    if baseline_issues.first.update_hours
      sum_closed_issues = baseline_issues.where(exclude: false, status: "Closed").sum(:spent_hours)
      sum_rejected_issues = baseline_issues.where(exclude: false, status: "Rejected").sum(:spent_hours)
      sum_normal_issues = baseline_issues.where("exclude = false and status != 'Closed' and status != 'Rejected'").sum(:estimated_hours)
      sum_closed_issues+sum_rejected_issues+sum_normal_issues
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
    planned_value_by_week[Date.today.beginning_of_week].nil? ? budget_at_completion : planned_value_by_week[Date.today.beginning_of_week]
  end

  private
    
    def calculate_planned_value_by_week
      planned_value_by_week = {}
      (start_date.beginning_of_week..end_date).each do |date|
        planned_value_by_week[date.beginning_of_week] = 0
      end

      baseline_issues.each do |baseline_issue|
        next if baseline_issue.exclude || baseline_issue.estimated_hours_for_chart == 0
        baseline_issue.days.each do |day|
          planned_value_by_week[day.beginning_of_week] += baseline_issue.hours_per_day unless planned_value_by_week[day.beginning_of_week].nil?
        end
      end
      planned_value_by_week.each_with_object({}) { |(k, v), h| h[k] = v + (h.values.last||0)  }
    end
end