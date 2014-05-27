require File.expand_path('../../test_helper', __FILE__)

class BaselineIssueTest < ActiveSupport::TestCase

  def test_if_end_date_is_not_nil 
  	version = BaselineVersion.create(effective_date: 1.day.from_now)
  	issue = BaselineIssue.create(baseline_version_id: version.id, due_date: Date.today)
  	assert_not_nil issue.end_date
  	assert_equal Date.today, issue.end_date
  end

end
