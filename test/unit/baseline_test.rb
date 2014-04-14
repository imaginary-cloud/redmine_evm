require File.expand_path('../../test_helper', __FILE__)

class BaselinesTest < ActiveSupport::TestCase
  fixtures :projects, :baselines, :baseline_issues, :baseline_versions, :versions, :issues

  ActiveRecord::Fixtures.create_fixtures(Redmine::Plugin.find(:redmine_evm).directory + '/test/fixtures/',
                                         [:baselines,
                                         :baseline_issues,
                                         :baseline_versions,
                                         :versions, 
                                         :issues])

  def setup
    @baseline = baselines(:baselines_001)
  end

  def new_baseline
    Baseline.create(project: projects(:projects_001), name: 'Initial plan',
                    due_date: Time.new(2014,05,14).to_date, description: "we love rails", start_date: Time.new(2014,01,05).to_date)
  end

  def test_create
    b = new_baseline
    assert b.save, "Did not save"
    assert_equal "Initial plan" , b.name
    assert_equal Time.new(2014,05,14).to_date, b.due_date
    assert_equal "we love rails", b.description
    assert_equal 1, b.project_id
  end

  def test_create_versions
    baseline = new_baseline
    id = baseline.id
    baseline.create_versions(projects(:projects_001).versions)
    baseline_version=baseline.baseline_versions.last
    assert_equal id, baseline_version.baseline_id
    assert_equal "0.1", baseline_version.name
    assert_equal "Beta", baseline_version.description
  end

  def test_create_issues
    baseline = new_baseline
    baseline.create_issues(projects(:projects_001).issues)
    baseline_issue = baseline.baseline_issues.first
    # puts baseline_issue.inspect
    assert_equal "Can't print recipes", baseline_issue.subject
    #assert_equal 1 , baseline_issue.baseline_version_id
  end

  def test_if_planned_value_returns_value
    assert_not_nil @baseline.planned_value
    assert_equal 19 , @baseline.planned_value
  end

  def test_if_planned_value_by_week_returns_correct_hash
    planned_value_by_week = @baseline.planned_value_by_week
    assert_not_nil planned_value_by_week
    assert_equal 10, planned_value_by_week[Time.new(2006,07,30).to_date.beginning_of_week]
  end

  def test_if_destroy_deletes_associated_data
    @baseline.destroy 
    assert_equal [], @baseline.baseline_issues
  end

  # def test_if_planned_value_for_chart_returns
  #   b = Baseline.find(1)
  #   assert_not_nil b.planned_value_for_chart
  # end

end
