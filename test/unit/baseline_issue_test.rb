require File.expand_path('../../test_helper', __FILE__)

class BaselineIssueTest < ActiveSupport::TestCase
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

  def test_if_end_date_is_not_nil 
  	assert_not_nil @baseline.baseline_issues.first.get_end_date
  	assert_equal Date.new(2013,01,02), @baseline.baseline_issues.first.get_end_date
  end

end
