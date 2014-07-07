class AddIsClosedToBaselineVersions < ActiveRecord::Migration
  def up
    add_column :baseline_versions, :is_closed, :boolean, :default => false
  end

  def down
    remove_column :baseline_versions, :is_closed
  end
end