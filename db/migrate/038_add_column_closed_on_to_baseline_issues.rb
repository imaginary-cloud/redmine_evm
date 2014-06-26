class AddColumnClosedOnToBaselineIssues < ActiveRecord::Migration
  def up
    add_column :baseline_issues, :closed_on, :datetime
  end

  def down
    remove_column :baseline_issues, :closed_on
  end
end
