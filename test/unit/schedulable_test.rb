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
    @baseline_version = baseline_versions(:baseline_versions_001)
  end

  def test_if_baseline_planned_value_returns_value
    assert_not_nil @baseline.planned_value
    assert_equal 19 , @baseline.planned_value
  end

  def test_if_baseline_planned_value_by_week_returns_correct_hash
    planned_value_by_week = @baseline.planned_value_by_week
    assert_not_nil planned_value_by_week
    assert_equal 10, planned_value_by_week[Time.new(2006,07,30).to_date.beginning_of_week]
  end

  def test_if_baseline_version_planned_value_returns_value
    assert_not_nil @baseline_version.planned_value
    assert_equal 19 , @baseline.planned_value
  end

  def test_if_baseline_version_planned_value_by_week_returns_correct_hash
    planned_value_by_week = @baseline_version.planned_value_by_week
    assert_not_nil planned_value_by_week
    assert_equal 10, planned_value_by_week[Time.new(2006,07,30).to_date.beginning_of_week]
  end

end