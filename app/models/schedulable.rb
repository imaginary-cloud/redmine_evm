module Schedulable

  # Returns PV from version.
  def planned_value
    baseline_issues.sum(:estimated_time)
  end

  def planned_value_by_week
    planned_value_by_weeks = {}
    time = 0
    (start_date.to_date..end_date.to_date).each do |key|
      time += baseline_issues.select{ |i| i.end_date == key }.sum(&:estimated_time)
      planned_value_by_weeks[key.beginning_of_week] = time
    end
    planned_value_by_weeks
  end
end