class BaselineIssue < ActiveRecord::Base
  unloadable

  belongs_to :baseline
  belongs_to :baseline_version

  def days
    @days ||= (start_date..end_date).to_a
  end

  def hours_per_day
    @hours_per_day ||= estimated_hours / number_of_days 
  end

  private

    # def end_date 
    #   @end_date ||= get_end_date
    # end

    def number_of_days
      days.size
    end

    def end_date
      baseline_version ? due_date || baseline_version.end_date : due_date || baseline.due_date
    end
end
