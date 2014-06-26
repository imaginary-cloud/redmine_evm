require File.expand_path('../../test_helper', __FILE__)

class ForecastableTest < ActiveSupport::TestCase
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
    @project  = Project.find(1)
    @baseline = @project.baselines.first
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

  def test_if_estimate_at_completion_duration_returns_value
    assert_equal 74.83333333333333, @baseline.estimate_at_completion_duration
  end

  def test_if_earned_schedule_returns_value
    assert_equal 0.16666666666666666, @baseline.earned_schedule
  end

  def test_if_actual_forecast_line_returns_array
    forecast_line = @baseline.actual_cost_forecast_line
    assert_not_nil forecast_line
    assert_equal @baseline.estimate_at_completion_cost, forecast_line[1][1]
  end

  def test_if_earned_forecast_line_returns_array
    forecast_line = @baseline.earned_value_forecast_line
    assert_not_nil forecast_line
    assert_equal @baseline.planned_value_at_completion, forecast_line[1][1]
  end

  def test_if_end_date_for_top_line_returns_value
    assert_not_nil @baseline.end_date_for_top_line
  end

  def test_if_bac_top_line_returns_array
    bac_top_line = @baseline.bac_top_line
    assert_not_nil bac_top_line
    assert_equal 271.0, bac_top_line[0][1]
    assert_equal 271.0, bac_top_line[1][1]
    assert_equal @baseline.planned_value_at_completion, bac_top_line[0][1] 
  end
    
  def test_if_eac_top_line_returns_array
    eac_top_line = @baseline.eac_top_line
    assert_not_nil eac_top_line
    assert_equal 180.66666666666666, eac_top_line[0][1]
    assert_equal 180.66666666666666, eac_top_line[1][1]
    assert_equal @baseline.estimate_at_completion_cost, eac_top_line[0][1]
  end

end