class FixColumnName < ActiveRecord::Migration
  def change
    rename_column :baseline_issues, :time_weeks, :time_week
  end
end