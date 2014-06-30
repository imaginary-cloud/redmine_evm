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
        earned_value_by_week = Hash.new { |h, k| h[k] = 0 }

        fixed_issues.each do |fixed_issue|
          fixed_issue_dates = fixed_issue.dates
          next if fixed_issue.estimated_hours.nil?

          fixed_issues_days = (fixed_issue_dates[0].to_date..fixed_issue_dates[1].to_date).to_a
          hoursPerDay = fixed_issue.estimated_hours / fixed_issues_days.size 
        
          fixed_issues_days.each do |day|
            earned_value_by_week[day.beginning_of_week] += hoursPerDay * fixed_issue.done_ratio/100.0 
          end
        end
        earned_value_by_week.each_with_object({}) { |(k, v), h| h[k] = v + (h.values.last||0)  }
      end

      private
        def start_date_for_chart
          start_date ? start_date : created_on
        end

        def end_date_for_chart #due date para o earned value tem que ser a data da ultima alteração.
          due_date ? due_date : Date.toda
        end
    end  
  end
end

unless Version.included_modules.include?(RedmineEvm::Patches::VersionPatch)
  Version.send(:include, RedmineEvm::Patches::VersionPatch)
end