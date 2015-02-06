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
    @baseline = Baseline.find(1)
    @project = @baseline.project
  end

  def test_estimate_at_completion
    assert_equal 180.66666666666666, @baseline.estimate_at_completion_cost
  end

  def test_estimate_to_complete
    assert_equal 173.66666666666666, @baseline.estimate_to_complete
  end

  def test_variance_at_completion
    assert_equal 90.33333333333334, @baseline.variance_at_completion
  end

  def test_planned_duration
    pending "this was once working but needs to be reviewed for current data"
    assert_equal 75, @baseline.planned_duration
  end

  def test_if_earned_schedule_returns_value
    pending "this was once working but needs to be reviewed for current data"
    assert_equal 0.125, @baseline.earned_schedule
  end

  def test_estimate_at_completion_duration
    pending "this was once working but needs to be reviewed for current data"
    assert_equal 74.875, @baseline.estimate_at_completion_duration
  end

  def test_actual_forecast_line
    forecast_line = @baseline.actual_cost_forecast_line
    assert_not_nil forecast_line
    assert_equal @baseline.estimate_at_completion_cost, forecast_line[1][1]
  end

  def test_earned_forecast_line
    forecast_line = @baseline.earned_value_forecast_line
    assert_not_nil forecast_line
    assert_equal @baseline.budget_at_completion, forecast_line[1][1]
  end

  def test_end_date_for_top_line
    assert_equal Date.new(2014,06,20), @baseline.end_date_for_top_line
  end

  def test_if_bac_top_line_returns_array
    bac_top_line = @baseline.bac_top_line
    assert_not_nil bac_top_line
    assert_equal 271.0, bac_top_line[0][1]
    assert_equal 271.0, bac_top_line[1][1]
    assert_equal @baseline.budget_at_completion, bac_top_line[0][1] 
  end
    
  def test_if_eac_top_line_returns_array
    eac_top_line = @baseline.eac_top_line
    assert_not_nil eac_top_line
    assert_equal 180.66666666666666, eac_top_line[0][1]
    assert_equal 180.66666666666666, eac_top_line[1][1]
    assert_equal @baseline.estimate_at_completion_cost, eac_top_line[0][1]
  end

end