require File.expand_path('../../test_helper', __FILE__)

class BaselineVersionTest < ActiveSupport::TestCase
  fixtures :projects,
           :issues,
           :versions

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/',
                                         [:baselines,
                                          :baseline_issues,
                                          :baseline_versions])

  def test_if_end_date_is_not_nil 
    baseline = Baseline.create(name: "Teste", due_date: 5.days.from_now, project_id: 1)
    version = BaselineVersion.create(baseline_id: baseline.id)
    version2 = BaselineVersion.create(effective_date: Date.today)
    assert_not_nil version.end_date
    #assert_equal baseline.due_date, version.end_date
    assert_not_nil version2.end_date
    assert_equal Date.today, version2.end_date
  end

  # def test_if_planned_value_returns_value
  #   b = Baseline.find(1)
  #   baseline_version = b.baseline_versions.find(1)
  #   assert_not_nil baseline_version.planned_value
  #   assert_equal 19, baseline_version.planned_value
  # end

  # def test_if_planned_value_by_week_returns
  #   b = Baseline.find(1)
  #   baseline_version = b.baseline_versions.find(1)
  #   assert_not_nil baseline_version.planned_value_by_week
  # end

end
