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
        puts "Summed"
        puts summed_time_entries
        
        unless summed_time_entries.nil?
          puts "Start data: #{get_start_date(baseline_id).to_date.beginning_of_week}"
          (get_start_date(baseline_id).to_date.beginning_of_week..final_date.to_date).each do |key|
            unless summed_time_entries[key].nil?
              puts "Time"
              puts time
              time += summed_time_entries[key]
            end
            actual_cost_by_weeks[key.beginning_of_week] = time      #time_entry to the beggining od week
          end
        else
          actual_cost_by_weeks={0=>0}
        end

        actual_cost_by_weeks
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
        #test hash order
        nh = {}
        earned_value_by_week.keys.sort.each do |k|
          nh[k] = earned_value_by_week[k]
        end
        if Date.today < baseline_versions.where(baseline_id: baseline_id, original_version_id: id).first.end_date
          dat = Date.today
        else
          dat = baseline_versions.where(baseline_id: baseline_id, original_version_id: id).first.end_date
        end
        unless nh.empty?
          if nh.keys.last+1 <= dat
            (nh.keys.last+1..dat).each do |date|
              nh[date.beginning_of_week] = 0 unless nh[date.beginning_of_week] 
            end
          end  
        end

        nh.each_with_object({}) { |(k, v), h| h[k] = v + (h.values.last||0)  } 
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
    end  
  end
end

unless Version.included_modules.include?(RedmineEvm::Patches::VersionPatch)
  Version.send(:include, RedmineEvm::Patches::VersionPatch)
end