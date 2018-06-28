module Schedulable
  
  #Returns the Budget at Complete (BAC), the planned value at project completion.
  def budget_at_completion 
    if baseline_issues.first.update_hours
      sum_closed_issues_array = baseline_issues.where(exclude: false, is_closed: true)
                                               .collect { |baseline_issue| baseline_issue.spent_hours * baseline_issue.issue.user_rate }
      sum_normal_issues_array = baseline_issues.where(exclude: false, is_closed: false)
                                               .collect { |baseline_issue| baseline_issue.estimated_hours || 0 * baseline_issue.issue.user_rate }
      sum_closed_issues = sum_closed_issues_array.reduce(:+).to_f || 0
      sum_normal_issues = sum_normal_issues_array.reduce(:+).to_f || 0
      sum_closed_issues + sum_normal_issues
    else
      sum_not_excluded_array = baseline_issues.where(exclude: false)
                                              .collect { |baseline_issue| baseline_issue.estimated_hours || 0 * baseline_issue.issue.user_rate }
      sum_not_excluded_array.reduce(:+).to_f || 0
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
          next if baseline_issue.exclude || baseline_issue.estimated_rates_for_chart == 0 || !baseline_issue.is_leaf
          baseline_issue.days.each do |day|
            planned_value_by_week[day] += baseline_issue.rates_per_day unless planned_value_by_week[day].nil?
          end
        end  
      end
      planned_value_by_week.each_with_object({}) { |(k, v), h| h[k] = v + (h.values.last||0)  }
    end
end