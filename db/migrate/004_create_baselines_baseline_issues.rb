class CreateBaselinesBaselineIssues < ActiveRecord::Migration
  def change
    create_table :baselines_baseline_issues, :id => false do |t|
      t.integer :baseline_id
      t.integer :baseline_issue_id
    end
  end
end