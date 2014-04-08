module Schedulable

  # Returns PV from version.
  def planned_value
    baseline_issues.sum(:estimated_time)
  end

  # Returns PV by week. Key is a date corresponding to the beginning of the week from a set of issues, Value is the week's PV.
  def planned_value_by_week
    pv_by_week = Hash.new(0)
    baseline_issues.each do |issue|
      issues_week = issue.end_date.beginning_of_week ||= issue.start_date.beginning_of_week
      unless issues_week.nil? || issue.estimated_time.nil?
        pv_by_week[issues_week] += issue.estimated_time
      end
    end
    return pv_by_week
  end

  # Returns sum of PV in weeks from start_date to end_date, to be used in EVM charts.
  def planned_value_for_chart
    final_result = Hash.new(0)
    pv_sum = 0
    pv_by_week = planned_value_by_week
    (start_date.to_date...end_date.to_date).select(&:monday?).each do |date|
      pv_sum += pv_by_week[date]
      final_result[date] = pv_sum
    end
    return final_result
  end

end