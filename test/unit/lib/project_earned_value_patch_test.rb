require File.expand_path('../../../test_helper', __FILE__)

class ProjectEarnedValuePatchTest < ActiveSupport::TestCase
  fixtures :projects,
           :issues,
           :versions,
           :time_entries


  def test_if_earned_value_returns_value
    project = Project.find(1)
    project.issues.second.estimated_hours = 10
    assert_equal 3, project.earned_value
  end

  def test_if_earned_value_by_week_returns_correct_hash
    project = Project.find(1)
    assert_not_nil project.earned_value_by_week
    #assert_equal 10, acutal_cost_by_week[Time.new(2006,07,30).to_date.beginning_of_week]
  end

end