require File.expand_path('../../../test_helper', __FILE__)

class ProjectActualCostPatchTest < ActiveSupport::TestCase
  fixtures :projects,
           :issues,
           :versions,
           :time_entries


  def test_if_actual_cost_returns_value
    project = Project.find(1)
    assert_equal 155.25, project.actual_cost
  end

  def test_if_actual_cost_by_week_returns_correct_hash
    project = Project.find(1)
    actual_cost_by_week = project.actual_cost_by_week
    assert_equal 150.0, actual_cost_by_week[Time.new(2007,3,12).to_date.beginning_of_week]
  end

end