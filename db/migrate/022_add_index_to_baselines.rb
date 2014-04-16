class AddIndexToBaselines < ActiveRecord::Migration
  def change
    add_index :baselines, :project_id
  end
end