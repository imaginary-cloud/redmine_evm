require File.expand_path('../../test_helper', __FILE__)

class BaselineVersionTest < ActiveSupport::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issue_statuses,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries

ActiveRecord::Fixtures.create_fixtures(Redmine::Plugin.find(:redmine_evm).directory + '/test/fixtures/',
                                         [ :issues, 
                                           :time_entries,
                                           :time_entries,
                                           :versions,
                                           :baselines,
                                           :baseline_issues,
                                           :baseline_versions ])

  def setup
    @baseline_version = BaselineVersion.first
  end

  def test_start_date
    version = @baseline_version
    start_date_with_first_element = version.start_date
    start_date_without_first_element = (
      first_issue = version.baseline_issues.order(start_date: :asc).first
      assert first_issue, "the first issue should not be nil"
      assert_equal first_issue.start_date, start_date_with_first_element,
                   "the start date should be the same as of the first issue"
      first_issue.update_attributes(exclude: true)
      version.reset_start_date!
      version.start_date
    )
    assert start_date_with_first_element < start_date_without_first_element, <<-STR
      "when the first baseline issue is excluded the start date should be changed"
    STR

  end
end
