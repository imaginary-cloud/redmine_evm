require File.expand_path('../../test_helper', __FILE__)

class BaselineVersionTest < ActiveSupport::TestCase

  def test_if_end_date_returns_value
    baseline = Baseline.create(name: "Teste", due_date: 5.days.from_now, project_id: 1)
    version = BaselineVersion.create(baseline_id: baseline.id, effective_date: Date.today)
    assert_not_nil version.end_date
    assert_equal Date.today, version.end_date
  end

end
