require File.expand_path('../../test_helper', __FILE__)

class BaselineVersionTest < ActiveSupport::TestCase
  fixtures :projects,
           :issues,
           :versions

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

  def test_if_end_date_is_not_nil 
    baseline = Baseline.create(name: "Teste", due_date: 5.days.from_now)
    version = BaselineVersion.create(baseline_id: baseline.id)
    version2 = BaselineVersion.create(effective_date: Date.today)
    assert_not_nil version.end_date
    #assert_equal baseline.due_date, version.end_date
    assert_not_nil version2.end_date
    assert_equal Date.today, version2.end_date
  end

  def test_if_start_date_is_not_null
    baseline = Baseline.create(name: "test baseline", due_date: Date.today, project_id: 1, start_date: Date.today)
    baseline_version = BaselineVersion.create(baseline_id: baseline.id)
    assert_not_nil baseline_version.get_start_date
  end

end
