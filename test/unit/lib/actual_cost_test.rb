require File.expand_path('../../../test_helper', __FILE__)

class ActualCostTest < ActiveSupport::TestCase
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

  def test_actual_cost
    assert_equal 7.0, @project.actual_cost(@baseline)
  end

  def test_actual_cost_by_week
    assert_equal 7.0, @project.actual_cost_by_week(@baseline).to_a.last[1]
  end

  def test_summed_time_entries
    assert_equal 3, @project.summed_time_entries(@baseline).keys.count
    assert_equal 7.0, @project.summed_time_entries(@baseline).values.sum
  end

  def test_version_actual_cost
    version = @project.versions.find(165)
    assert_equal 0, version.actual_cost(@baseline)
  end

  def test_version_actual_cost_by_week
    version = @project.versions.find(165)
    assert_equal [], version.actual_cost_by_week(@baseline).to_a
  end

end