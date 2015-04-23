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

      def days_from_start start_date
        dates2 = dates(start_date)
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

      def days
        dates2 = dates(nil)
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

      def hours_per_day_from_start_date update_hours, baseline_id, start_date
        estimated_hours_for_chart(update_hours, baseline_id) / number_of_days_from_start_date(start_date)
      end

      def lastBaselineEstimatedHours
        baseline_issues.last.estimated_hours unless baseline_issues.last.nil?
      end

      private
      def dates(pre_start_date)
        dates = []
        if time_entries.empty?
          selected_journals = []
          journals.each do |journal|
            journal.details.each do |journal_detail|
              if journal_detail.prop_key == 'done_ratio' && journal_detail.value.to_i > 0
                selected_journals << journal_detail.journal
              end
            end
          end
          dates[0] = selected_journals.last.created_on unless selected_journals.first.nil?
          dates[0] = start_date? ? start_date : created_on if dates[0].nil?
        else
          dates[0] = time_entries.first.spent_on || time_entries.first.created_on
        end

        unless pre_start_date == nil
          if pre_start_date.to_date > dates[0].to_date
            dates[0] = pre_start_date.to_date
          end
        end

        closed? ? dates[1] = closed_on : dates[1] = updated_on
        dates
      end

      def number_of_days
        days.size
      end

      def number_of_days_from_start_date start_date
        days_from_start(start_date).size
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
