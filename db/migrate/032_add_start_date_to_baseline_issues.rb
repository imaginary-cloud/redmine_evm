class AddStartDateToBaselineIssues < ActiveRecord::Migration
  def up
    add_column :baseline_issues, :start_date, :date
  end

  def down
    remove_column :baseline_issues, :start_date
  end
end