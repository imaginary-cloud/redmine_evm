require File.expand_path('../../../test_helper', __FILE__)

class EarnedValueTest < ActiveSupport::TestCase
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

  def test_earned_value
    assert_equal 10.5, @project.earned_value(@baseline)
  end

  def test_earned_value_by_week
    earned_value_by_week = @project.earned_value_by_week(@baseline)
    assert_not_nil earned_value_by_week
    assert_equal 10.5, earned_value_by_week.to_a.last[1].round(2)
  end

  def test_version_earned_value_by_week
    version = @project.versions.find(165)
    assert_equal 0.0, version.earned_value_by_week(@baseline.id).to_a.last[1]
  end

end