class AddTimeInWeeksToBaselineIssues < ActiveRecord::Migration
  def change
    add_column :baseline_issues, :time_weeks, :integer
  end
end