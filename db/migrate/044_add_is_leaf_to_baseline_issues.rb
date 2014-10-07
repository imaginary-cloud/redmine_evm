class AddIsLeafToBaselineIssues < ActiveRecord::Migration

  def self.up
    add_column :baseline_issues, :is_leaf, :boolean, :default => true
  end

  def self.down
    remove_column :baseline_issues, :is_leaf
  end

end