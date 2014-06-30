module RedmineEvm
  module Patches

    module ProjectPatch
      def self.included(base) # :nodoc:

        base.extend(ClassMethods)

        base.send(:include, ProjectInstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          has_many :baselines
        end
      end
    end

    module ClassMethods  
    end

    module ProjectInstanceMethods

      def get_chart_data baseline, forecast_is_enabled
        chart_data = []
        chart_data << convert_to_chart(baseline.planned_value_by_week)
        chart_data << convert_to_chart(self.actual_cost_by_week(baseline))
        chart_data << convert_to_chart(self.earned_value_by_week(baseline))
        if(forecast_is_enabled)
          chart_data << convert_to_chart(baseline.actual_cost_forecast_line)
          chart_data << convert_to_chart(baseline.earned_value_forecast_line)
          chart_data << convert_to_chart(baseline.bac_top_line)
          chart_data << convert_to_chart(baseline.eac_top_line)
        end
        chart_data
      end

      def maximum_date
        maximum_start_date ||= [
          issues.maximum('start_date'),
          shared_versions.maximum('effective_date'),
          Issue.fixed_version(shared_versions).maximum('start_date')
          ].compact.max

          [maximum_start_date,due_date].max
        end

      # isto esta assim porque comentei no eraned value patch so para experimentar o novo
      def earned_value_by_week baseline_id
        earned_value_by_week = Hash.new { |h, k| h[k] = 0 }

        issues.each do |issue|
          if baselines.find(baseline_id).update_hours
            if issue.closed? 
              next if issue.spent_hours == 0
              issue_dates = issue.dates
              issues_days = (issue_dates[0].to_date..issue_dates[1].to_date).to_a
              hoursPerDay = issue.spent_hours / issues_days.size 
            else
              next if issue.estimated_hours.nil?
              issue_dates = issue.dates
              issues_days = (issue_dates[0].to_date..issue_dates[1].to_date).to_a
              hoursPerDay = issue.estimated_hours / issues_days.size 
            end
          else
            next if issue.estimated_hours.nil?
            issue_dates = issue.dates
            issues_days = (issue_dates[0].to_date..issue_dates[1].to_date).to_a
            hoursPerDay = issue.estimated_hours / issues_days.size 
          end
          issues_days.each do |day|
            earned_value_by_week[day.beginning_of_week] += hoursPerDay * issue.done_ratio/100.0 
          end
        end
        earned_value_by_week.each_with_object({}) { |(k, v), h| h[k] = v + (h.values.last||0)  }
      end

      def earned_value baseline_id
        sum_earned_value = 0
        issues.each do |issue|
          #baselines.find(baseline_id).baseline_issues.where
          if baselines.find(baseline_id).update_hours
            if issue.closed?
              next if issue.spent_hours == 0
              sum_earned_value += issue.spent_hours * (issue.done_ratio / 100.0)    
            else
              next if issue.estimated_hours.nil?
              sum_earned_value += issue.estimated_hours * (issue.done_ratio / 100.0)  
            end
          else
            next if issue.estimated_hours.nil?
            sum_earned_value += issue.estimated_hours * (issue.done_ratio / 100.0)
          end
        end
        sum_earned_value
      end

    end

  end
end

unless Project.included_modules.include?(RedmineEvm::Patches::ProjectPatch)
  Project.send(:include, RedmineEvm::Patches::ProjectPatch)
end