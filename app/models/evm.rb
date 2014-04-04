class Evm
  include ActiveModel::Model


  def calculate_evm baseline_or_baseline_version
    start_date = baseline_or_baseline_version.start_date
    end_date = baseline_or_baseline_version.end_date

    issues = baseline_or_baseline_version.baseline_issues
    week_year = []
    planned_value = []
    time = 0;

    while start_date < end_date
      date = start_date.strftime('%U/%Y')
      week_year << date

      issues.each do |issue|
        if issue.end_date.strftime('%U/%Y')==date ? time+=issue.estimated_time : time+=0
      end
      planned_value << time
      start_date+=1.week
    end
  end
    [planned_value, week_year]
  end

end