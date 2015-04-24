module RedmineEvm
  module Patches

    module IssuePatch
      def self.included(base) # :nodoc:

        base.extend(ClassMethods)

        base.send(:include, IssueInstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          has_many :baseline_issues, :foreign_key => 'original_issue_id'
          scope :non_excluded, ->{
            self.where(excluded: false)
          }
        end
      end
    end

    module ClassMethods
    end

    module IssueInstanceMethods
      @@days_by_week = {}

      def days
        dates2 = dates
        if @@days_by_week["#{dates2[0].to_date} #{dates2[1].to_date}"]
          @@days_by_week["#{dates2[0].to_date} #{dates2[1].to_date}"]
        else
          array = []
          (dates2[0].to_date..dates2[1].to_date).each do |day|
            array<< day
          end
          @@days_by_week["#{dates2[0].to_date} #{dates2[1].to_date}"] = array.uniq
          array.uniq
        end
      end

      def hours_per_day update_hours, baseline_id
        estimated_hours_for_chart(update_hours, baseline_id) / number_of_days
      end

      def lastBaselineEstimatedHours
        baseline_issues.last.estimated_hours unless baseline_issues.last.nil?
      end

      private
      def dates
        dates = []

        journals_with_progress_change = []
        journals.each do |journal|
          journal.details.each do |journal_detail|
            if journal_detail.prop_key == 'done_ratio' && journal_detail.value.to_i > 0
              journals_with_progress_change << journal_detail.journal
            end
          end
        end
        progess_start_date = journals_with_progress_change.first.created_on unless journals_with_progress_change.first.nil?
        progess_start_date = start_date? ? start_date : created_on if progess_start_date.nil?

        unless time_entries.empty?
          time_entries_start_date = time_entries.first.spent_on || time_entries.first.created_on
          if time_entries_start_date.to_date < progess_start_date.to_date
            progess_start_date = time_entries_start_date
          end
        end

        dates[0] = progess_start_date

        closed? ? dates[1] = closed_on : dates[1] = updated_on
        dates
      end

      def number_of_days
        days.size
      end

      def estimated_hours_for_chart update_hours, baseline_id
        baseline_issue = baseline_issues.find_by_baseline_id(baseline_id)

        if update_hours && closed? && baseline_issue.is_closed
          baseline_issue.spent_hours || 0
        else
          baseline_issue.estimated_hours || 0
        end

      end

    end
  end
end

unless Issue.included_modules.include?(RedmineEvm::Patches::IssuePatch)
  Issue.send(:include, RedmineEvm::Patches::IssuePatch)
end
