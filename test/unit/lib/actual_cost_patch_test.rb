require File.expand_path('../../../test_helper', __FILE__)

class ActualCostPatchTest < ActiveSupport::TestCase
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
    @baseline = Baseline.first
    @project = Project.find(1)
  end

  def test_if_actual_cost_returns_value
    assert_equal 7.0, @baseline.actual_cost
  end

  def test_if_actual_cost_by_week_returns_correct_hash
    assert_equal 7.0, @project.actual_cost_by_week(@baseline.id).to_a.last[1]
  end

  def test_if_summed_issues_function_returns_something
    assert_not_nil @project.get_summed_time_entries(@baseline.id)
  end

  def test_if_get_issues_for_actual_cost_returns
    assert_not_nil @project.get_non_excluded_issues(@baseline.id)
  end

  def test_when_time_entries_have_no_issue_associated
    assert_equal false , @project.has_time_entries_with_no_issue
  end

  def test_when_time_entries_have_log_date_before_project_start_date
    assert_equal false, @project.has_time_entries_before_start_date(@baseline.id)
  end

  def test_if_version_returns_actual_cost
    version = @project.versions.first
    assert_equal 0, version.actual_cost(@baseline.id)
  end

  def test_if_version_returns_actual_cost_by_week
    version = @project.versions.first
    assert_equal 0, version.actual_cost_by_week(@baseline.id).to_a.last[1]
  end

  #Test if in the actual time the actual_cost_by_week for the chart is equal to actual_cost function.
  def test_if_actualcost_is_equal_to_current_in_actualcost_by_week
    current_ac_in_by_week = @project.actual_cost_by_week(@baseline.id)[Date.today.beginning_of_week]
    current_ac = @baseline.actual_cost
    assert_equal current_ac, current_ac_in_by_week
  end

  def test_if_get_issues_filter_issues_from_excluded_versions
    bv = @baseline.baseline_versions.first
    bv.exclude = true
    bv.save
    assert_equal 4, @project.get_non_excluded_issues(@baseline.id).count
  end

end