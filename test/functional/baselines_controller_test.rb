require File.expand_path('../../test_helper', __FILE__)

class BaselinesControllerTest < ActionController::TestCase

  fixtures :projects,
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
    [:baselines])

  def test_create
    @request.session[:user_id] = 2 
    assert_difference 'Baseline.count' do
      post :create, :project_id => '1', :baseline => {:name => 'test_add_baseline'}
    end
    assert_redirected_to '/projects/ecookbook/settings/baselines'
    baseline = Baseline.find_by_name('test_add_baseline')
    assert_not_nil baseline 
    assert_equal 1, baseline.project_id
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
