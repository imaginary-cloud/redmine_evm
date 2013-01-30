
require File.expand_path('../../../test_helper', __FILE__)

class IndicatorsLogicTest < ActiveSupport::TestCase
  fixtures :issues, :issue_statuses,
           :projects, :trackers, :projects_trackers, :users, :members,
           :enumerations
  include IndicatorsLogic

  def test_one_issue
    with_settings :non_working_week_days => %w(6 7) do
      project = Project.new(:name => 'evm', :identifier => 'evm', :tracker_ids => [1])
      assert project.save
      issue1 = Issue.new(:project_id => project.id, :tracker_id => 1, :author_id => 3,
                         :status_id => 1, :priority => IssuePriority.all.first,
                         :subject => 'issue1',
                         :description => '')
      assert issue1.save
      issue1.estimated_hours = 3
      issue1.start_date = '2013-01-24'
      issue1.due_date   = '2013-01-24'
      issue1.done_ratio = 50
      assert issue1.save
      assert_equal 3, issue1.estimated_hours
      assert_equal '2013-01-24'.to_date, project.start_date

      time_entries_by_week_and_year, issues = IndicatorsLogic::retrive_data(project)
      assert_equal 0, time_entries_by_week_and_year.size
      assert_equal 1, issues.size
      assert_equal issue1.id, issues[0].id

      indicators = IndicatorsLogic::calc_indicators(project)
      arr = indicators[0]
      assert_equal 4, arr.size
      assert_equal ["4/2013", 0.0, 3.0, 1.5], arr[1]
      assert_equal ["5/2013", 0.0, 3.0, 1.5], arr[2]
      assert_equal ["6/2013", 0.0, 3.0, 1.5], arr[3]
    end
  end

  def test_one_issue_one_time_entry
    with_settings :non_working_week_days => %w(6 7) do
      project = Project.new(:name => 'evm', :identifier => 'evm', :tracker_ids => [1])
      assert project.save
      issue1 = Issue.new(:project_id => project.id, :tracker_id => 1, :author_id => 3,
                         :status_id => 1, :priority => IssuePriority.all.first,
                         :subject => 'issue1',
                         :description => '')
      assert issue1.save
      issue1.estimated_hours = 3
      issue1.start_date = '2013-01-24'
      issue1.due_date   = '2013-01-24'
      issue1.done_ratio = 50
      assert issue1.save
      assert_equal 3, issue1.estimated_hours
      assert_equal '2013-01-24'.to_date, project.start_date

      anon     = User.anonymous
      activity = TimeEntryActivity.find_by_name('Design')
      TimeEntry.create(:spent_on => '2013-01-24',
                       :hours    => 1,
                       :issue    => issue1,
                       :project  => project,
                       :user     => anon,
                       :activity => activity)

      time_entries_by_week_and_year, issues = IndicatorsLogic::retrive_data(project)
      assert_equal 1, time_entries_by_week_and_year.size
      assert_equal [[4, 2013]], time_entries_by_week_and_year.keys
      assert_equal [1.0], time_entries_by_week_and_year.values
      assert_equal 1, issues.size
      assert_equal issue1.id, issues[0].id

      indicators = IndicatorsLogic::calc_indicators(project)
      arr = indicators[0]
      assert_equal 3, arr.size
      assert_equal ["4/2013", 1.0, 3.0, 1.5], arr[1]
      assert_equal ["5/2013", 1.0, 3.0, 1.5], arr[2]
    end
  end
end
