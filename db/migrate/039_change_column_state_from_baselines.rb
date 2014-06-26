class ChangeColumnStateFromBaselines < ActiveRecord::Migration
  def up
    change_column :baselines, :state, :string, default: "Current"
  end

  def down
    change_column :baselines, :state, :string, default: nil
  end
end