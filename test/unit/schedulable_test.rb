require File.expand_path('../../test_helper', __FILE__)

class SchedulableTest < ActiveSupport::TestCase
  fixtures :projects

  ActiveRecord::Fixtures.create_fixtures(Redmine::Plugin.find(:redmine_evm).directory + '/test/fixtures/',
                                         [ :issues, 
                                           :time_entries,
                                           :time_entries,
                                           :versions,
                                           :baselines,
                                           :baseline_issues,
                                           :baseline_versions ])

  def setup
    @project  = Project.find(1)
    @baseline = @project.baselines.first
  end

  def test_if_baseline_planned_value_returns_value
    assert_not_nil @baseline.planned_value
    assert_equal 271.0 , @baseline.planned_value
  end

  def test_if_baseline_planned_value_at_the_end_returns_value
    assert_equal 271.0, @baseline.planned_value_at_completion
  end

  def test_if_baseline_planned_value_by_week_returns_correct_hash
    planned_value_by_week = @baseline.planned_value_by_week
    assert_not_nil planned_value_by_week
    assert_equal 271.0, planned_value_by_week.to_a.last[1]
  end

  def test_if_baseline_version_planned_value_returns_value
    baseline_version = @baseline.baseline_versions.first
    assert_not_nil baseline_version.planned_value
    assert_equal 240 , baseline_version.planned_value
  end

  def test_if_baseline_version_planned_value_by_week_returns_correct_hash
    baseline_version = @baseline.baseline_versions.first
    assert_not_nil baseline_version.planned_value_by_week
    assert_equal 240, baseline_version.planned_value_by_week.to_a.last[1]
  end

  #Test if in the actual time the planned_value_by_week for the chart is equal to planned_value function.
  def test_if_pv_is_equal_to_current_in_pv_by_week
    current_pv_in_by_week = @baseline.planned_value_by_week[Date.today.beginning_of_week]
    current_pv = @baseline.planned_value
    assert_equal current_pv, current_pv_in_by_week
  end

end