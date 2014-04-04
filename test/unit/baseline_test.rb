require File.expand_path('../../test_helper', __FILE__)

class BaselineTest < ActiveSupport::TestCase


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

end
