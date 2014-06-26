class RemoveColumnStartDateFromBaselineVersions < ActiveRecord::Migration
  def up
    remove_column :baseline_versions, :start_date
  end

  def down
    add_column :baseline_versions, :start_date, :date
  end
end
