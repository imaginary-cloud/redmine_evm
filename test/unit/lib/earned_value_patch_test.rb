require File.expand_path('../../../test_helper', __FILE__)

class EarnedValuePatchTest < ActiveSupport::TestCase
  fixtures :projects,
           :versions

ActiveRecord::Fixtures.create_fixtures(Redmine::Plugin.find(:redmine_evm).directory + '/test/fixtures/',
                                         [ :issues, 
                                           :time_entries ])          

  def test_if_earned_value_returns_value
    project = Project.find(1)
    baseline_id = project.baselines.first.id
    assert_equal 40.0, project.earned_value(baseline_id)
  end

  def test_if_earned_value_by_week_returns_correct_hash
    project = Project.find(1)
    baseline_id = project.baselines.first.id
    earned_value_by_week = project.earned_value_by_week(baseline_id)
    assert_not_nil earned_value_by_week
    assert_equal 40.0, earned_value_by_week.to_a.last[1]
  end

  def test_if_get_issues_returns_something
    project = Project.find(1)
    baseline_id = project.baselines.first.id
    assert_not_nil project.get_issues(baseline_id)
  end

  def test_if_version_returns_earned_value
    project = Project.find(1)
    baseline_id = project.baselines.first.id
    version = project.versions.first
    assert_equal 0.0, version.earned_value(baseline_id)
  end

  def test_if_version_returns_earned_value_by_week
    project = Project.find(1)
    baseline_id = project.baselines.first.id
    version = project.versions.first
    assert_equal 0.0, version.earned_value_by_week(baseline_id).to_a.last[1]
  end

end