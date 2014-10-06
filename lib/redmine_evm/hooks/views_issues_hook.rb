module RedmineEvm
  module Hooks
    class ViewsIssuesHook < Redmine::Hook::ViewListener
      render_on :view_issues_show_details_bottom, :partial => "baselines/baseline_issue_estimated_time"
    end
  end
end
