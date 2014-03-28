class AddCreatedOnToBaselines < ActiveRecord::Migration
  def change
    add_column :baselines, :created_on, :timestamp
  end
end