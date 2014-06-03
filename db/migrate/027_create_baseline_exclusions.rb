class CreateBaselineExclusions < ActiveRecord::Migration
  def change
    create_table :baseline_exclusions do |t|
      t.integer :baseline_id
      t.integer :version_id
    end
  end
end
