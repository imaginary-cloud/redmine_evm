require File.expand_path('../../../test_helper', __FILE__)

class ProjectPatchTest < ActiveSupport::TestCase
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

  def test_filter_excluded_issues
    assert_equal 17, @project.filter_excluded_issues(@baseline).count
  end

  def test_filter_excluded_issues_with_one_version_excluded
    baseline_version = @baseline.baseline_versions.find(93)
    baseline_version.exclude = true
    baseline_version.save
    baseline_version.baseline_issues.each do |bi|
      bi.exclude = true
      bi.save
    end
    assert_equal 6, @project.filter_excluded_issues(@baseline).count
  end
  
  def test_filter_excluded_issues_with_all_versions_excluded
    @baseline.baseline_versions.each do |bv|
      bv.exclude = true
      bv.baseline_issues.each do |bi|
        bi.exclude = true
        bi.save
      end
      bv.save
    end
    assert_equal 3, @project.filter_excluded_issues(@baseline).count
  end

  def test_maximum_chart_date
    pending "this was once working but needs to be reviewed for current data"
    assert_equal Date.new(2014,06,16), @project.maximum_chart_date(@baseline)
  end

  def test_maximum_date
    assert_equal Date.new(2014,06,21), @project.maximum_date
  end

  #Isto esta no sitio errado
  def test_when_time_entries_have_no_issue_associated
    assert_equal false , @project.has_time_entries_with_no_issue
  end

end