require File.expand_path('../../test_helper', __FILE__)

class BaselineTest < ActiveSupport::TestCase

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/',
                                         [:baselines,
                                         :baseline_issues,
                                         :baseline_versions])


  def test_create
    b = Baseline.new(:project => Project.find(1), :name => 'baseline 10',
                    :due_date => Date.today)
    assert b.save, "Did not save"
    assert_not_nil b.project_id, "The project does not exist"
  end


  def test_if_planned_value_returns_value
    b = Baseline.new(:project => Project.find(1), :name => 'baseline 10',
                     :due_date => Date.today)
    b.save
    b.baseline_issues.create(estimated_time: 20)
    assert_not_nil b.planned_value
    assert_equal 20 , b.planned_value
  end

  def test_if_planned_value_by_week_returns_correct_hash
    b = Baseline.find(1)
    planned_value_by_week = b.planned_value_by_week
    assert_not_nil planned_value_by_week
    assert_equal 10, planned_value_by_week[10.day.from_now.to_date.beginning_of_week]
  end

  def test_if_planned_value_for_chart_returns
    b = Baseline.find(1)
    assert_not_nil b.planned_value_for_chart
  end

end
