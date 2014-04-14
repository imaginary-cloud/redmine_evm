require File.expand_path('../../test_helper', __FILE__)

class BaselineIssueTest < ActiveSupport::TestCase

  # Replace this with your real tests.
def test_if_end_date_is_not_nil 
	version = BaselineVersion.create(effective_date: 1.day.from_now)
	issue = BaselineIssue.create(baseline_version_id: version.id)
	issue2 = BaselineIssue.create(due_date: Date.today)
	assert_not_nil issue.end_date
	assert_not_nil issue2.end_date
end



end
