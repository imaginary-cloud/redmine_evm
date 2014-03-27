class CreateBaselineIssues < ActiveRecord::Migration
  def change
    create_table :baseline_issues do |t|
      t.integer :original_issue_id
      t.integer :estimated_time
      t.date :due_date
    end
  end
end
