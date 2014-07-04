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
    @baseline = Baseline.find(1)
    @project = @baseline.project
  end

  def test_baseline_budget_at_completion
    assert_equal 271.0, @baseline.budget_at_completion
  end

  def test_baseline_planned_value
    assert_equal 271.0, @baseline.planned_value
  end

  def test_baseline_planned_value_by_week
    planned_value_by_week = @baseline.planned_value_by_week
    assert_not_nil planned_value_by_week
    assert_equal 271.0, planned_value_by_week.to_a.last[1].round(2)
  end

  def test_baseline_version_planned_value
    baseline_version = @baseline.baseline_versions.first
    assert_not_nil baseline_version.planned_value
    assert_equal 240.0 , baseline_version.planned_value.round(2)
  end

  def test_baseline_version_planned_value_by_week
    baseline_version = @baseline.baseline_versions.first
    assert_not_nil baseline_version.planned_value_by_week
    assert_equal 240, baseline_version.planned_value_by_week.to_a.last[1].round(2)
  end

end