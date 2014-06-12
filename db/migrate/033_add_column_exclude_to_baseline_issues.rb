class AddColumnExcludeToBaselineIssues < ActiveRecord::Migration
  def up
    add_column :baseline_issues, :exclude, :boolean
  end

  def down
    remove_column :baseline_issues, :exclude
  end
end