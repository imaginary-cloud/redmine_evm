module RedmineEvm
  module Patches

    module VersionPatch
      def self.included(base) # :nodoc:

        base.extend(ClassMethods)

        base.send(:include, VersionInstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          has_many :baseline_versions, :foreign_key => 'original_version_id'
        end
      end
    end

    module ClassMethods  
    end

    module VersionInstanceMethods

      def get_chart_data baseline
        baseline_version = baseline.baseline_versions.where(original_version_id: self.id, exclude: false).first
        chart_data = []
        unless baseline_version.nil?
          chart_data << convert_to_chart(baseline_version.planned_value_by_week)
          chart_data << convert_to_chart(self.actual_cost_by_week(baseline))
          chart_data << convert_to_chart(self.earned_value_by_week(baseline))
        end
      end

      def earned_value_by_week baseline_id
        earned_value_by_week = {}

        (start_date_for_chart.beginning_of_week..end_date_for_chart).each do |date|
          earned_value_by_week[date.beginning_of_week] = 0
        end

        fixed_issues.each do |fixed_issue|
          unless fixed_issue.estimated_hours.nil?
            dates = fixed_issue_dates fixed_issue
            fixed_issue_days = (dates[0].to_date..dates[1].to_date).to_a
            hours_per_day = fixed_issue.estimated_hours / fixed_issue_days.size

            fixed_issue_days.each do |day|
              earned_value_by_week[day.beginning_of_week] += hours_per_day * fixed_issue.done_ratio/100.0 unless earned_value_by_week[day.beginning_of_week].nil?
            end
          end
        end
        earned_value_by_week.each_with_object({}) { |(k, v), h| h[k] = v + (h.values.last||0)  }
      end

      private
        def start_date_for_chart
          start_date ? start_date : created_on
        end

        def end_date_for_chart
          due_date ? due_date : Date.today
        end

        def fixed_issue_dates fixed_issue
          dates = []
          selected_journals = fixed_issue.journals.select {|journal| journal.journalized.done_ratio > 0}
          dates[0] = selected_journals.first.created_on
          if fixed_issue.status.name == "Closed"
            dates[1] = fixed_issue.closed_on
          else
            dates[1] = fixed_issue.updated_on
          end
          dates
        end
    end  
  end
end

unless Version.included_modules.include?(RedmineEvm::Patches::VersionPatch)
  Version.send(:include, RedmineEvm::Patches::VersionPatch)
end