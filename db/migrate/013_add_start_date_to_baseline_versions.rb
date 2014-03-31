class AddStartDateToBaselineVersions < ActiveRecord::Migration
  def change
    add_column :baseline_versions, :start_date, :date
  end
end