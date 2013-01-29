
require File.expand_path('../../../test_helper', __FILE__)

class IndicatorsLogicTest < ActiveSupport::TestCase
  fixtures :issues, :issue_statuses,
           :projects, :trackers, :projects_trackers, :users, :members,
           :enumerations
  include IndicatorsLogic

  def test_one_issue
    project = Project.new(:name => 'evm', :identifier => 'evm', :tracker_ids => [1])
    assert project.save
    issue1 = Issue.new(:project_id => project.id, :tracker_id => 1, :author_id => 3,
                       :status_id => 1, :priority => IssuePriority.all.first,
                       :subject => 'issue1',
                       :description => 'IssueTest#test_create')
    assert issue1.save
    issue1.estimated_hours = 3
    issue1.start_date = '2013-01-24'
    issue1.due_date   = '2013-01-24'
    issue1.done_ratio = 50
    assert issue1.save
    assert_equal 3, issue1.estimated_hours
    assert_equal '2013-01-24'.to_date, project.start_date

    indicators = IndicatorsLogic::calc_indicators(project)
    arr = indicators[0]
    assert_equal ["4/2013", 0.0, 3.0, 1.5], arr[1]
  end

  def test_one_issue_on_friday
    project = Project.new(:name => 'evm', :identifier => 'evm', :tracker_ids => [1])
    assert project.save
    issue1 = Issue.new(:project_id => project.id, :tracker_id => 1, :author_id => 3,
                       :status_id => 1, :priority => IssuePriority.all.first,
                       :subject => 'issue1',
                       :description => 'IssueTest#test_create')
    assert issue1.save
    issue1.estimated_hours = 3
    issue1.start_date = '2013-01-25'
    issue1.due_date   = '2013-01-25'
    issue1.done_ratio = 50
    assert issue1.save
    assert_equal 3, issue1.estimated_hours
    assert_equal '2013-01-25'.to_date, project.start_date

    indicators = IndicatorsLogic::calc_indicators(project)
    arr = indicators[0]
    assert_equal ["4/2013", 0.0, 3.0, 1.5], arr[1]
  end
end
