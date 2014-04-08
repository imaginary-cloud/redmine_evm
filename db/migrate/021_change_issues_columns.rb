class ChangeIssuesColumns < ActiveRecord::Migration
  def up
    change_column :baseline_issues, :description, :text
  end

  def down
    change_column :baseline_issues, :description, :string
  end
end