require File.expand_path('../../../test_helper', __FILE__)

class ActualCostPatchTest < ActiveSupport::TestCase
  fixtures :projects,
           :versions

ActiveRecord::Fixtures.create_fixtures(Redmine::Plugin.find(:redmine_evm).directory + '/test/fixtures/',
                                         [ :issues, 
                                           :time_entries ])         

  def test_if_actual_cost_returns_value
    project = Project.find(1)
    assert_equal 35.0, project.actual_cost
  end

  def test_if_actual_cost_by_week_returns_correct_hash
    project = Project.find(1)
    actual_cost_by_week = project.actual_cost_by_week
    assert_equal 35.0, actual_cost_by_week.to_a.last[1]
  end

  def test_if_summed_issues_function_returns_something
    project = Project.find(1)
    assert_not_nil project.get_summed_time_entries
  end

  def test_when_time_entries_have_no_issue_associated
    project = Project.find(1)
    assert_equal false , project.has_time_entries_with_no_issue
  end

  def test_when_time_entries_have_log_date_before_project_start_date
    project = Project.find(1)
    assert_equal false, project.has_time_entries_before_start_date
  end

  def test_if_version_returns_actual_cost
    version = Project.find(1).versions.first
    assert_equal 0, version.actual_cost
  end

  def test_if_version_returns_actual_cost_by_week
    version = Project.find(1).versions.first
    assert_equal 0, version.actual_cost_by_week.to_a.last[1]
  end

end