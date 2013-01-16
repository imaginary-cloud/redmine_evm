module IndicatorsLogic

  def self.retrive_data(project_or_version)
    if project_or_version.instance_of? Version
      my_project = project_or_version.project
      my_version = project_or_version
      ary_reported_time_week_year =
        my_project.time_entries.where(
          :issue_id=>Issue.where(:fixed_version_id => my_version.id)).sum(
            :hours, :group => [:tweek, :tyear], :order => [:tyear, :tweek])
      ary_all_issues = my_version.fixed_issues
    else
      my_project = project_or_version
      ary_reported_time_week_year =
        my_project.time_entries.sum(
          :hours, :group => [:tweek, :tyear], :order => [:tyear, :tweek])
      ary_all_issues = my_project.issues
    end
    [ary_reported_time_week_year, ary_all_issues]
  end

  def self.calc_indicators(my_project_or_version, ary_reported_time_week_year, ary_all_issues)
    check_end_date = my_project_or_version.due_date || Time.now.to_date
    check_ary_reported_time_week_year =
      ary_reported_time_week_year.empty? ? Time.now.to_date :
        Date.ordinal(ary_reported_time_week_year.keys.last[1],
                       ary_reported_time_week_year.keys.last[0] * 7 - 3)
    if ary_all_issues.maximum(:start_date)
      check_ary_all_issues = ary_all_issues.empty? ? Time.now.to_date : ary_all_issues.maximum(:start_date)
      my_project_or_version_end_date =
          [check_end_date,check_ary_reported_time_week_year, check_ary_all_issues].max
    else
      my_project_or_version_end_date =
          [check_end_date,check_ary_reported_time_week_year].max
    end
    ary_weeks_years = []
    real_start_date = [
          (my_project_or_version.start_date.nil? ?
            (Time.now.to_date - 1.day) :
              my_project_or_version.start_date.beginning_of_week),
          (ary_reported_time_week_year.empty? ?
            Time.now.to_date :
            Date.ordinal(ary_reported_time_week_year.keys.first[1],
                           ary_reported_time_week_year.keys.first[0] * 7 - 3))
        ].min
    while real_start_date < my_project_or_version_end_date + 1.week
      ary_weeks_years << [real_start_date.cweek, real_start_date.cwyear]
      real_start_date += 1.week
    end
    hash_weeks_years = {}
    ary_weeks_years.each{|e| hash_weeks_years[e] = [0,0,0]}
    done_ratio = 0
    ary_all_issues.each do |issue|
      next if !issue.leaf?
      start_issue_date = issue.start_date? ? issue.start_date : my_project_or_version.start_date
      end_issue_date = issue.due_date? ? issue.due_date : my_project_or_version_end_date
      estimated_time = issue.estimated_hours? ? issue.estimated_hours : 0
      done_ratio = (issue.done_ratio / 100.0)
      if (not start_issue_date.nil?) && (not end_issue_date.nil?)
        ary_dates = (start_issue_date..end_issue_date).to_a
        ary_dates.delete_if{|x| x.wday == 5 || x.wday == 6}
        if ary_dates.any? && estimated_time != 0
          hoursPerDay = estimated_time / ary_dates.size
          ary_dates.each do |day|
            week = day.cweek
            year = day.cwyear
            hash_weeks_years[[week,year]][1] += hoursPerDay
            hash_weeks_years[[week,year]][2] += hoursPerDay * done_ratio
          end
        end
      end
    end
    ary_data_week_years = [['week', 'ActualCost', 'PlannedCost', 'EarnedValue']]
    sum_real = 0
    sum_planned = 0
    sum_earned = 0
    ary_weeks_years.each do |k|
      v = hash_weeks_years[k]
      sum_real += ary_reported_time_week_year.has_key?(k)? ary_reported_time_week_year[k] : 0
      v[0] = sum_real
      sum_planned += v[1]
      v[1] = sum_planned
      sum_earned += v[2]
      v[2] = sum_earned
      ary_data_week_years.push(
        [k[0].to_s + "/" + k[1].to_s,
         (v[0] * 100).round / 100.0,
         (v[1] * 100).round / 100.0,
         (v[2] * 100).round / 100.0])
    end
    cpi = hash_weeks_years.values.last[0].zero? ?
            0 : hash_weeks_years.values.last[2] / hash_weeks_years.values.last[0]
    spi = hash_weeks_years.values.last[1].zero? ?
            0 : hash_weeks_years.values.last[2] / hash_weeks_years.values.last[1]
    [ary_data_week_years, (cpi * 1000).round / 1000.0, (spi * 1000).round / 1000.0]
  end

  def self.included(base)
    base.send :helper_method, :calc_indicators, :retrive_data if base.respond_to? :helper_method
  end
end
