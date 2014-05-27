require File.expand_path('../../test_helper', __FILE__)

class SchedulableTest < ActiveSupport::TestCase
  fixtures :projects, :baselines, :baseline_issues, :baseline_versions, :versions, :issues

  ActiveRecord::Fixtures.create_fixtures(Redmine::Plugin.find(:redmine_evm).directory + '/test/fixtures/',
   [:baselines,
     :baseline_issues,
     :baseline_versions,
     ])

  def setup
    @baseline = baselines(:baselines_001)
  end

  def test_if_baseline_planned_value_returns_value
    assert_not_nil @baseline.planned_value
    assert_equal 29.0 , @baseline.planned_value
  end

  def test_if_baseline_planned_value_by_week_returns_correct_hash
    planned_value_by_week = @baseline.planned_value_by_week
    assert_not_nil planned_value_by_week
    assert_equal 29.0, planned_value_by_week.to_a.last[1]
  end

  def test_if_baseline_version_planned_value_returns_value
    baseline_version = @baseline.baseline_versions.first
    assert_not_nil baseline_version.planned_value
    assert_equal 0 , baseline_version.planned_value
  end

  def test_if_baseline_version_planned_value_by_week_returns_correct_hash
    baseline_version = @baseline.baseline_versions.first
    assert_not_nil baseline_version.planned_value_by_week
    assert_equal 0, baseline_version.planned_value_by_week.to_a.last[1]
  end

end