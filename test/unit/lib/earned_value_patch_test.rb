require File.expand_path('../../../test_helper', __FILE__)

class EarnedValuePatchTest < ActiveSupport::TestCase
  fixtures :projects,
           :issues,
           :versions,
           :time_entries


  def test_if_earned_value_returns_value
    project = Project.find(1)
    baseline_id = project.baselines.first.id
    project.issues.second.estimated_hours = 10
    assert_equal 5.0, project.earned_value(baseline_id)
  end

  def test_if_earned_value_by_week_returns_correct_hash
    project = Project.find(1)
    baseline_id = project.baselines.first.id
    assert_not_nil project.earned_value_by_week(baseline_id)
    #assert_equal 10, acutal_cost_by_week[Time.new(2006,07,30).to_date.beginning_of_week]
  end

end