class BaselineIssue < ActiveRecord::Base
  unloadable

  belongs_to :baseline
  belongs_to :baseline_version
  belongs_to :issue, foreign_key: 'original_issue_id'

  def days
    @days ||= (start_date_for_chart..end_date_for_chart).to_a
  end

  def hours_per_day
    @hours_per_day ||= estimated_hours_for_chart / number_of_days 
  end

  def estimated_hours_for_chart
    @estimated_hours ||= update_hours ? is_closed ? spent_hours : estimated_hours || 0 : estimated_hours || 0
  end

  private

    def start_date_for_chart 
      start_date ? start_date : baseline_version ? baseline_version.start_date : baseline.start_date
    end

    def end_date_for_chart
      if update_hours
        if is_closed
          closed_on.to_date
        else
          due_date ? due_date : baseline_version ? baseline_version.end_date : baseline.due_date
        end
      else
        due_date ? due_date : baseline_version ? baseline_version.end_date : baseline.due_date
      end
    end

    def number_of_days
      days.size
    end
end