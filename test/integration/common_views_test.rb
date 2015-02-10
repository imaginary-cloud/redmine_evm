require File.expand_path('../../test_helper', __FILE__)
#require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

class CommonViewsTest < ActionController::IntegrationTest
  fixtures :projects,
           :enabled_modules,
           :users,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :versions,
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

    ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/',
                            [:baselines, 
                             :roles])

  def setup
    RedmineEvm::TestCase.prepare

    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.env['HTTP_REFERER'] = '/'
  end

  # User 2 Manager (role 1) in project 1, email jsmith@somenet.foo
  # User 3 Developer (role 2) in project 1

  # test "View baselines list" do
  #   log_user("admin", "admin")
  #   get "/projects/1/settings/baselines"
  #   assert_response :success
  # end

  # test "View baseline edit" do
  #   log_user("admin", "admin")
  #   get "/baselines/1/edit"
  #   assert_response :success
  # end

  # test "View baseline" do
  #   log_user("admin", "admin")
  #   get "/baselines/1"
  #   assert_response :success
  # end

end