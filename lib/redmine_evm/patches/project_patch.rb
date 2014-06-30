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

      def filter_excluded_issues baseline_id
        issues.joins(:baseline_issues).where("baseline_issues.exclude = 0 AND baseline_issues.baseline_id = ?", baseline_id)
      end

      ##########ACTUAL COST#################

      def actual_cost baseline_id
        issues = filter_excluded_issues(baseline_id)
        issues.select('sum(hours) as sum_hours').joins(:time_entries).first.sum_hours || 0
      end

      def summed_time_entries baseline_id
        issues = filter_excluded_issues(baseline_id)
        query = issues.select('MAX(spent_on) AS spent_on, SUM(hours) AS sum_hours').
                joins(:time_entries).
                group('spent_on').collect { |issue| [issue.spent_on, issue.sum_hours] }
        Hash[query]
      end

      def actual_cost_by_week baseline_id
        actual_cost_by_weeks = {}
        time = 0

        #If it is not a old project
        final_date = get_end_date(baseline_id)
        date_today = Date.today
        if final_date > date_today      
          final_date = date_today
        end

        summed_time_entries = self.summed_time_entries(baseline_id)

        unless summed_time_entries.nil?
          (get_start_date(baseline_id).to_date.beginning_of_week..final_date.to_date).each do |key|
            unless summed_time_entries[key].nil?
              time += summed_time_entries[key]
            end
            actual_cost_by_weeks[key.beginning_of_week] = time      #time_entry to the beggining od week
          end
        else
          actual_cost_by_weeks={0=>0}
        end

        actual_cost_by_weeks
      end

      ###########EARNED VALUE##############

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

      def data_for_chart baseline, forecast_is_enabled
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

      def chart_end_date baseline
        end_dates = []
        unless baseline.planned_value_by_week.to_a.last.nil?
          end_dates << baseline.planned_value_by_week.to_a.last[0]
        end
        unless self.actual_cost_by_week(baseline).to_a.last.nil?
          end_dates << self.actual_cost_by_week(baseline).to_a.last[0]
        end
        unless self.earned_value_by_week(baseline).to_a.last.nil?
          end_dates << self.earned_value_by_week(baseline).to_a.last[0]
        end

        end_dates.max.nil? ? 0 : end_dates.max.to_time.to_i * 1000  #convert to to milliseconds for flot.js
      end

      def maximum_date
        maximum_start_date ||= [
          issues.maximum('start_date'),
          shared_versions.maximum('effective_date'),
          Issue.fixed_version(shared_versions).maximum('start_date')
          ].compact.max

        [maximum_start_date, due_date].max
      end

    end

  end
end

unless Project.included_modules.include?(RedmineEvm::Patches::ProjectPatch)
  Project.send(:include, RedmineEvm::Patches::ProjectPatch)
end