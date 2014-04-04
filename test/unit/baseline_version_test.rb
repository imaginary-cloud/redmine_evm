require File.expand_path('../../test_helper', __FILE__)

class BaselineVersionTest < ActiveSupport::TestCase

  def test_if_planned_value_returns_value
    b = Baseline.new(:project => Project.find(1), :name => 'baseline 10',
                     :due_date => Date.today)
    b.save
    new_baseline_version = b.baseline_versions.new
    new_baseline_version.id = 1
    new_baseline_version.save
    baseline_version = b.baseline_versions.first
    new_baseline_issue = baseline_version.baseline_issues.new(:estimated_time => 5)
    new_baseline_issue.id = 1
    new_baseline_issue.save
    assert_not_nil baseline_version.planned_value
    assert_equal 5 , baseline_version.planned_value
  end

end
