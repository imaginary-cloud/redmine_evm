require File.expand_path('../../test_helper', __FILE__)

class BaselineTest < ActiveSupport::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issue_statuses,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries

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

  should belong_to(:project)
  should have_many(:baseline_issues)
  should have_many(:baseline_versions)
  should validate_presence_of(:name)
  should validate_presence_of(:due_date)

  def new_baseline
    @project.baselines.create(name: 'Voo Baseline 2', due_date: Time.new(2014,05,14).to_date, description: "we love rails")
  end

  def test_create
    b = new_baseline
    assert b.save, "Did not save"
    assert_equal "Voo Baseline 2" , b.name
    assert_equal Time.new(2014,05,14).to_date, b.due_date
    assert_equal "we love rails", b.description
    assert_equal false, b.update_hours
    assert_equal 1, b.project_id
  end

  def test_create_versions
    baseline = new_baseline
    id = baseline.id
    versions_to_exclude = []
    update_hours = false
    baseline.create_versions(@project.versions,versions_to_exclude, update_hours)
    baseline_version = baseline.baseline_versions.where("original_version_id = ?", 165).first
    assert_equal id, baseline_version.baseline_id
    assert_equal "Acceptance Review", baseline_version.name
  end

  def test_create_issues
    baseline = new_baseline
    update_hours = false
    baseline.create_issues(@project.issues, update_hours)
    baseline_issue = baseline.baseline_issues.first
    assert_not_nil baseline_issue
  end

  def test_if_it_excludes_versions 
    versions_to_exclude = [164]
    baseline = new_baseline
    id = baseline.id
    update_hours  = false
    baseline.create_versions(@project.versions,versions_to_exclude, update_hours)
    assert_equal true, baseline.baseline_versions.where(original_version_id: 164).first.exclude
  end

  def test_if_it_updates_hours
    baseline_with_update = @project.baselines.create(name: 'Test Update', due_date: Date.new(2014,05,14), description: "updated hours enabled", update_hours: true )
    versions_to_exclude = []
    update_hours_param = true
    assert_equal true, baseline_with_update.update_hours # CHANGE TO TRUE
  end


  def test_if_destroy_deletes_associated_data
    @baseline.destroy 
    assert_equal [], @baseline.baseline_issues
  end

  def test_earned_value
    assert_equal 10.5, @project.earned_value(@baseline)
  end

  def test_actual_cost
    BaselineIssue.find(613).update_attributes(exclude: true)
    assert_equal 7 - Issue.find(4544).time_entries.first.hours , @project.actual_cost(@baseline)
  end

  def test_schedule_performance_index
    assert_equal 0.03874538745387454, @baseline.schedule_performance_index
  end

  def test_defacto_start_date_for_baseline
    BaselineIssue.find(613).update_attributes(exclude: true)
    assert_equal Time.new(2013,1,2), @project.defacto_start_date_for_baseline(@baseline)
    assert_not_equal @project.start_date, @project.defacto_start_date_for_baseline(@baseline)
  end

  def test_cost_performance_index
    assert_equal 1.5, @baseline.cost_performance_index
  end

  def test_schedule_variance
    assert_equal -260.5, @baseline.schedule_variance
  end

  def test_cost_variance
    assert_equal 3.5, @baseline.cost_variance
  end

  def test_if_actual_cost_is_equal_to_actual_cost_by_week
    actual_cost_by_week = @project.actual_cost_by_week(@baseline).to_a.last[1]
    actual_cost = @project.actual_cost(@baseline)
    assert_equal actual_cost, actual_cost_by_week.round(2)
  end

  def test_if_earned_value_is_equal_to_earned_value_by_week
    earned_value_by_week = @project.earned_value_by_week(@baseline).to_a.last[1]
    earned_value = @project.earned_value(@baseline)
    assert_equal earned_value, earned_value_by_week.round(2)
  end

  def test_if_budget_at_completion_is_equal_to_planned_value_by_week
    planned_value_by_week = @baseline.planned_value_by_week.to_a.last[1]
    budget_at_completion = @baseline.budget_at_completion
    assert_equal budget_at_completion, planned_value_by_week.round(2)
  end

end
