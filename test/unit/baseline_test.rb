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
    @baseline = Baseline.first
    @project = Project.find(1)
  end 

  should belong_to(:project)
  should have_many(:baseline_issues)
  should have_many(:baseline_versions)
  should have_many(:baseline_exclusions)
  should validate_presence_of(:name)
  should validate_presence_of(:due_date)

  def new_baseline
    Baseline.create(project: @project, name: 'Voo Baseline 2', due_date: Time.new(2014,05,14).to_date, description: "we love rails", start_date: Time.new(2014,01,05).to_date)
  end

  def test_create
    b = new_baseline
    assert b.save, "Did not save"
    assert_equal "Voo Baseline 2" , b.name
    assert_equal Time.new(2014,05,14).to_date, b.due_date
    assert_equal "we love rails", b.description
    assert_equal 1, b.project_id
  end

  def test_create_versions
    baseline = new_baseline
    id = baseline.id
    baseline.create_versions(@project.versions)
    baseline_version = baseline.baseline_versions.where("original_version_id = ?", 165).first
    assert_equal id, baseline_version.baseline_id
    assert_equal "Acceptance Review", baseline_version.name
  end

  def test_create_issues
    baseline = new_baseline
    baseline.create_issues(@project.issues)
    baseline_issue = baseline.baseline_issues.first
    assert_not_nil baseline_issue
  end

  def test_if_destroy_deletes_associated_data
    @baseline.destroy 
    assert_equal [], @baseline.baseline_issues
  end

  def test_if_earned_value_returns_value
    assert_equal 10.5, @baseline.earned_value 
  end

  def test_if_actual_cost_returns_value
    assert_equal 7, @baseline.actual_cost
  end

  def test_if_schedule_performance_index_returns_value
    assert_equal 0.03874538745387454, @baseline.schedule_performance_index
  end

  def test_if_cost_performance_index_returns_value
    assert_equal 1.5, @baseline.cost_performance_index
  end

  def test_if_schedule_variance_returns_value
    assert_equal -260.5, @baseline.schedule_variance
  end

  def test_if_cost_variance_returns_value
    assert_equal 3.5, @baseline.cost_variance
  end

  def test_if_budget_at_completion_returns_value
    assert_equal 271.0, @baseline.budget_at_completion
  end

  def test_if_estimate_at_completion_cost_returns_value
    assert_equal 180.66666666666666, @baseline.estimate_at_completion_cost
  end

  def test_if_estimate_to_complete_returns_value
    assert_equal 173.66666666666666, @baseline.estimate_to_complete
  end

  def test_if_variance_at_completion_returns_value
    assert_equal 90.33333333333334, @baseline.variance_at_completion
  end

  def test_if_planned_duration_returns_value
    assert_equal 75, @baseline.planned_duration
  end

  def test_if_actual_duration_returns_value
    assert_equal 76, @baseline.actual_duration  
  end

  # def test_if_earned_duration_returns_value
  #   assert_equal 0.0, @baseline.earned_duration
  # end

  def test_if_estimate_at_completion_duration_returns_value
    assert_equal 74.83333333333333, @baseline.estimate_at_completion_duration
  end

  def test_if_earned_schedule_returns_value
    assert_equal 0.16666666666666666, @baseline.earned_schedule
  end

  def test_if_actual_forecast_line_returns_array
    forecast_line = @baseline.actual_cost_forecast_line
    assert_not_nil forecast_line
  end

  # def test_if_earned_forecast_line_returns_array
  #   forecast_line = @baseline.earned_value_forecast_line
  #   assert_not_nil forecast_line
  # end

  def test_if_end_date_for_top_line_returns_value
    assert_not_nil @baseline.end_date_for_top_line
  end

  def test_if_bac_top_line_returns_array
    bac_top_line = @baseline.bac_top_line
    assert_not_nil bac_top_line
    assert_equal 271.0, bac_top_line[0][1]
    assert_equal 271.0, bac_top_line[1][1]
  end
    
  def test_if_eac_top_line_returns_array
    eac_top_line = @baseline.eac_top_line
    assert_not_nil eac_top_line
    assert_equal 180.66666666666666, eac_top_line[0][1]
    assert_equal 180.66666666666666, eac_top_line[1][1]
  end

  def test_if_actual_cost_is_equal_to_actual_cost_by_week
    actual_cost_by_week = @project.actual_cost_by_week(@baseline.id).to_a.last[1]
    actual_cost = @baseline.actual_cost
    assert_equal actual_cost, actual_cost_by_week
  end

  def test_if_earned_value_is_equal_to_earned_value_by_week
    earned_value_by_week = @project.earned_value_by_week(@baseline.id).to_a.last[1]
    earned_value = @baseline.earned_value
    assert_equal earned_value, earned_value_by_week
  end

  def test_if_palnned_value_is_equal_to_planned_value_by_week
    planned_value_by_week = @baseline.planned_value_by_week.to_a.last[1]
    planned_value = @baseline.planned_value
    assert_equal planned_value, planned_value_by_week
  end

end
