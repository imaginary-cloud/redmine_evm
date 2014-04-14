module Schedulable

  # Returns PV from version.
  def planned_value
    baseline_issues.sum(:estimated_time)
  end

  def planned_value_by_week
    planned_value_by_weeks = {}
    #sorted_issues = baseline_issues.sort_by {|date| date.end_date}
    time = 0
    (start_date.to_date...end_date.to_date).each do |key|
      time += baseline_issues.where(due_date: key).sum(:estimated_time)
      planned_value_by_weeks[key.beginning_of_week] = time
    end
    time += baseline_issues.where(due_date: nil).sum(:estimated_time) 
    planned_value_by_weeks[end_date.to_date.beginning_of_week] = time
    planned_value_by_weeks

    # planned_value_by_weeks = {}
    # (start_date.to_date...end_date.to_date).each do |key|
    #   planned_value_by_weeks[key.beginning_of_week] = 0
    # end

    # sorted_issues = baseline_issues.sort_by {|date| date.end_date}
    # time = 0

    # sorted_issues.each do |issue|
    #   issues_week =  issue.end_date.beginning_of_week 
    #   unless issues_week.nil? || issue.estimated_time.nil?
    #     time += issue.estimated_time
    #     planned_value_by_weeks[issues_week] = time
    #   end
    # end
    # planned_value_by_weeks
  end
end