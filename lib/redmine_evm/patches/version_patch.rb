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

      def filter_excluded_issues baseline_id
        fixed_issues.joins(:baseline_issues).where("baseline_issues.exclude = 0 AND baseline_issues.baseline_id = ?", baseline_id)
      end

      ##########ACTUAL COST###########
      
      def actual_cost baseline_id
        spent_hours
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

      #######EARNED VALUE#############

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

      def data_for_chart baseline
        #Need to show all versions but exclude the selected versions.
        baseline_version = baseline.baseline_versions.where(original_version_id: self.id, exclude: false).first

        chart_data = []
        puts "Current Version: #{self.name} | Is Excluded?  #{self.is_excluded(baseline)}"
        unless is_excluded(baseline)
          unless baseline_version.nil?
            chart_data << convert_to_chart(baseline_version.planned_value_by_week)
            chart_data << convert_to_chart(self.actual_cost_by_week(baseline))
            chart_data << convert_to_chart(self.earned_value_by_week(baseline))
          end
        end
      end

      def chart_end_date baseline
        end_dates = []
        baseline_version = self.baseline_versions.where(baseline_id: baseline).first
        unless baseline_version.planned_value_by_week.to_a.last.nil?
          end_dates << baseline_version.planned_value_by_week.to_a.last[0]
        end
        unless self.actual_cost_by_week(baseline).to_a.last.nil?
          end_dates << self.actual_cost_by_week(baseline).to_a.last[0]
        end
        unless self.earned_value_by_week(baseline).to_a.last.nil?
          end_dates << self.earned_value_by_week(baseline).to_a.last[0]
        end

        end_dates.max.nil? ? 0 : end_dates.max.to_time.to_i * 1000  #convert to to milliseconds for flot.js

      end

      def is_excluded baseline_id
        if self.baseline_versions.where("baseline_id = ?", baseline_id).first.nil?
          false
        else
          self.baseline_versions.where("baseline_id = ?", baseline_id).first.exclude
        end
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