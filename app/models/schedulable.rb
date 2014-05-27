module Schedulable

  #Returns the Budget at Complete (BAC), the planned value at project completion.
  def planned_value_at_completion
    baseline_issues.sum(:estimated_hours)
  end

  # #Returns the planned value by weeks.
  # def planned_value_by_week
  #   planned_value_by_weeks = {}
  #   time = 0
  #   (start_date.to_date..end_date.to_date).each do |key|
  #     time += baseline_issues.select{ |baseline_issue| baseline_issue.end_date == key }.sum(&:estimated_hours)
  #     planned_value_by_weeks[key.beginning_of_week] = time
  #   end
  #   planned_value_by_weeks
  # end

  #Returns the planned value by weeks.
  def planned_value_by_week
    result = baseline_issues.select('due_date, sum(estimated_hours) as estimated_hours')
                            .group('due_date').having('sum(estimated_hours)<>0')
                            .collect { |baseline_issue| [baseline_issue.due_date, baseline_issue.estimated_hours] }
    summed_baseline_issues = Hash[result]

    planned_value_by_weeks = {}
    time = 0
    (start_date.beginning_of_week..end_date).each do |key|
      unless summed_baseline_issues[key].nil?
        time += summed_baseline_issues[key]
      end
        planned_value_by_weeks[key.beginning_of_week] = time
    end

    unless summed_baseline_issues[nil].nil? #Check if there are issues with no due_date
      time += summed_baseline_issues[nil] #Issues with no due_date, add estimated_hours
    end
    planned_value_by_weeks[end_date.to_date.beginning_of_week] = time

    planned_value_by_weeks
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