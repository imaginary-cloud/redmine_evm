class AddProjectToRates < ActiveRecord::Migration

  def change
    add_column :rates, :project_id, :integer
    add_index :rates, :project_id
    add_index :rates, :user_id
  end

end