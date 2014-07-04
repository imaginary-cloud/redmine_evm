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

      def earned_value_by_week baseline_id
        earned_value_by_week = Hash.new { |h, k| h[k] = 0 }
        baseline_versions.find_by_baseline_id(baseline_id).update_hours ? update_hours = true : update_hours = false
        fixed_issues.each do |fixed_issue|
          fixed_issue.days.each do |day|
            earned_value_by_week[day.beginning_of_week] += fixed_issue.hours_per_day(update_hours, baseline_id) * fixed_issue.done_ratio/100.0 
          end
        end
        ordered_earned_value = order_earned_value earned_value_by_week
        extend_earned_value_to_final_date ordered_earned_value, baseline_id      end

      def data_for_chart baseline
        #Need to show all versions but exclude the selected versions.
        baseline_version = baseline.baseline_versions.where(original_version_id: self.id, exclude: false).first

        chart_data = []
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
        def order_earned_value earned_value
          ordered_earned_value = {}
          earned_value.keys.sort.each do |key|
            ordered_earned_value[key] = earned_value[key]
          end
          ordered_earned_value
        end

        def extend_earned_value_to_final_date ordered_earned_value, baseline_id
          if Date.today < baseline_versions.find_by_baseline_id(baseline_id).end_date
            dat = Date.today
          else
            dat = baseline_versions.find_by_baseline_id(baseline_id).end_date
          end
          unless ordered_earned_value.empty?
            if ordered_earned_value.keys.last+1 <= dat
              (ordered_earned_value.keys.last+1..dat).each do |date|
                ordered_earned_value[date.beginning_of_week] = 0 unless ordered_earned_value[date.beginning_of_week] 
              end
            end  
          end
          ordered_earned_value.each_with_object({}) { |(key, v), h| h[key] = v + (h.values.last||0) }
        end
    end  
  end
end

unless Version.included_modules.include?(RedmineEvm::Patches::VersionPatch)
  Version.send(:include, RedmineEvm::Patches::VersionPatch)
end