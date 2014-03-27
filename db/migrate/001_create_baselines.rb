class CreateBaselines < ActiveRecord::Migration
  def change
    create_table :baselines do |t|
      t.string :name
      t.date :due_date
      t.string :description
      t.string :state
      t.integer :project_id
    end
  end
end
