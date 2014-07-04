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

      def actual_cost baseline_id
        spent_hours
      end

      def summed_time_entries baseline_id
        issues = self.fixed_issues
        query = issues.select('MAX(spent_on) AS spent_on, SUM(hours) AS sum_hours').
                joins(:time_entries).
                group('spent_on').collect { |issue| [issue.spent_on, issue.sum_hours] }
        Hash[query]
      end

      def actual_cost_by_week baseline
        issues = self.fixed_issues
        actual_cost_by_weeks = {}
        time = 0

        start_date = issues.select("min(spent_on) as spent_on").joins(:time_entries).first.spent_on || project.start_date
        #end_date   = issues.select("max(spent_on) as spent_on").joins(:time_entries).first.spent_on || start_date

        final_date = maximum_chart_date(baseline)
        date_today = Date.today
        if final_date > date_today      
          final_date = date_today
        end

        summed_time_entries = self.summed_time_entries(baseline)
        
        unless summed_time_entries.empty?
          (start_date.beginning_of_week..final_date.to_date).each do |key|
            unless summed_time_entries[key].nil?
              time += summed_time_entries[key]
            end
            actual_cost_by_weeks[key.beginning_of_week] = time      #time_entry to the beggining od week
          end
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

        chart_data = {}
        unless is_excluded(baseline) #If a version is not excluded.
          unless baseline_version.nil?
            chart_data['planned_value'] = convert_to_chart(baseline_version.planned_value_by_week)
            chart_data['actual_cost']   = convert_to_chart(self.actual_cost_by_week(baseline))
            chart_data['earned_value']  = convert_to_chart(self.earned_value_by_week(baseline))
          end
        end
        chart_data #Data ready for chart flot.js to consume.
      end

      def maximum_chart_date baseline
        issues = self.fixed_issues

        dates = []
        dates << baseline_versions.where(baseline_id: baseline).first.try(:end_date) #planned value line, returns nil if not in a baseline
        dates << issues.select("max(spent_on) as spent_on").joins(:time_entries).first.spent_on #actual cost line
        dates << issues.joins(:baseline_issues).where("baseline_issues.update_hours = 0").map(&:updated_on).compact.max.try(:to_date) #earned value
        dates << issues.joins(:baseline_issues).where("baseline_issues.update_hours = 1").map(&:closed_on).compact.max.try(:to_date) #earnedvalue

        dates << project.start_date #If there is no data yet

        dates.compact.max
        #dates.max.nil? ? 0 : dates.max
      end

      def is_excluded baseline_id
        baseline_version = self.baseline_versions.where("baseline_id = ?", baseline_id).first #BaselineVersion of this version
        if baseline_version.nil?
          false #Does not have a baseline version so it is not excluded.
        else
          baseline_version.exclude
        end
      end
    end  
  end
end

unless Version.included_modules.include?(RedmineEvm::Patches::VersionPatch)
  Version.send(:include, RedmineEvm::Patches::VersionPatch)
end