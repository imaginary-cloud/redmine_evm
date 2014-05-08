require File.expand_path('../../test_helper', __FILE__)

class BaselineTest < ActiveSupport::TestCase
  fixtures :projects, :baselines, :baseline_issues, :baseline_versions, :versions, :issues

  ActiveRecord::Fixtures.create_fixtures(Redmine::Plugin.find(:redmine_evm).directory + '/test/fixtures/',
                                         [:baselines,
                                         :baseline_issues,
                                         :baseline_versions,
                                         ])

  should belong_to(:project)
  should have_many(:baseline_issues)
  should have_many(:baseline_versions)
  should validate_presence_of(:name)
  should validate_presence_of(:due_date)

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
    baseline_version = baseline.baseline_versions.where("original_version_id = ?", 1).first
    assert_equal id, baseline_version.baseline_id
    #assert_equal "0.1", baseline_version.name
    assert_equal "Beta", baseline_version.description
  end

  def test_create_issues
    baseline = new_baseline
    baseline.create_issues(projects(:projects_001).issues)
    baseline_issue = baseline.baseline_issues.first
    assert_equal 1, baseline_issue.id
  end

  def test_if_destroy_deletes_associated_data
    @baseline.destroy 
    assert_equal [], @baseline.baseline_issues
  end

end
