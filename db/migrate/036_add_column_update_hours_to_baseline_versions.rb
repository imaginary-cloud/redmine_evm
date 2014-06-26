class AddColumnUpdateHoursToBaselineVersions < ActiveRecord::Migration
  def up
    add_column :baseline_versions, :update_hours, :boolean
  end

  def down
    remove_column :baseline_versions, :update_hours
  end
end
