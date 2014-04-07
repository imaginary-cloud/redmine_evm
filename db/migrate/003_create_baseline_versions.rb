class CreateBaselineVersions < ActiveRecord::Migration
  def change
    create_table :baseline_versions do |t|
      t.integer :original_version_id
      t.date :effective_date
    end
  end
end
