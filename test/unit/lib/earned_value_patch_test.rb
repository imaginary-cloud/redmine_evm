require File.expand_path('../../../test_helper', __FILE__)

class EarnedValuePatchTest < ActiveSupport::TestCase
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

  def test_if_earned_value_returns_value
    assert_equal 10.5, @project.earned_value(@baseline.id)
  end

  def test_if_earned_value_by_week_returns_correct_hash
    earned_value_by_week = @project.earned_value_by_week(@baseline.id)
    assert_not_nil earned_value_by_week
    assert_equal 10.5, earned_value_by_week.to_a.last[1]
  end

  def test_if_get_issues_returns_something
    assert_not_nil @project.get_issues_for_earned_value(@baseline.id)
  end

  def test_if_version_returns_earned_value
    version = @project.versions.first
    assert_equal 0.0, version.earned_value(@baseline.id)
  end

  def test_if_version_returns_earned_value_by_week
    version = @project.versions.first
    assert_equal 0.0, version.earned_value_by_week(@baseline.id).to_a.last[1]
  end

  #Test if in the actual time the earned_value_by_week for the chart is equal to earned_value function.
  def test_if_earnedvalue_is_equal_to_current_in_earnedvalue_by_week
    current_ev_in_by_week = @project.earned_value_by_week(@baseline.id)[Date.today.beginning_of_week]
    current_ev = @baseline.earned_value
    assert_equal current_ev, current_ev_in_by_week
  end

end