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
        end_date   = issues.select("max(spent_on) as spent_on").joins(:time_entries).first.spent_on || start_date

        final_date = [maximum_chart_date(baseline), end_date].compact.max
        date_today = Date.today
        if final_date > date_today
          final_date = date_today
        end


        summed_time_entries = self.summed_time_entries(baseline)

        unless summed_time_entries.empty?
          (start_date..final_date.to_date).each do |key|
            unless summed_time_entries[key].nil?
              time += summed_time_entries[key]
            end
            actual_cost_by_weeks[key] = time      #time_entry to the beggining od week
          end
        end

        actual_cost_by_weeks
      end

      def earned_value_by_week baseline_id
        earned_value_by_week = Hash.new { |h, k| h[k] = 0 }
        baseline_versions.find_by_baseline_id(baseline_id).update_hours ? update_hours = true : update_hours = false
        relevant_issues = fixed_issues.reject do |issue|
          issue.baseline_issues.find_by_baseline_id(baseline_id).nil? || !issue.leaf?
        end
        relevant_issues.each do |fixed_issue|
          fixed_issue.days.each do |day|
            earned_value_by_week[day] += fixed_issue.hours_per_day(update_hours, baseline_id) * fixed_issue.done_ratio/100.0
          end
        end
        ordered_earned_value = order_earned_value earned_value_by_week
        extend_earned_value_to_final_date ordered_earned_value, baseline_id
      end

      def data_for_chart baseline
        #Need to show all versions but exclude the selected versions.
        baseline_version = baseline.baseline_versions.where(original_version_id: self.id, exclude: false).first

        chart_data = {}
        unless is_excluded(baseline) #If a version is not excluded.
          unless baseline_version.nil?
            chart_data['planned_value'] = convert_to_chart(baseline_version.planned_value_by_week)
            chart_data['earned_value']  = convert_to_chart(self.earned_value_by_week(baseline))
          end
          chart_data['actual_cost']   = convert_to_chart(self.actual_cost_by_week(baseline))
        end
        chart_data #Data ready for chart flot.js to consume.
      end

      def maximum_chart_date baseline
        issues = self.fixed_issues

        dates = []
        dates << baseline_versions.where(baseline_id: baseline, original_version_id: id)
                                  .first.try(:end_date) #planned value line, returns nil if not in a baseline
        dates << issues.select("max(spent_on) as spent_on").joins(:time_entries).first.spent_on #actual cost line
        dates << issues.map(&:updated_on).compact.max.try(:to_date) #earned value
        dates << issues.map(&:closed_on).compact.max.try(:to_date) #earnedvalue
        #fixed_issues updated on e closed on ...
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
                ordered_earned_value[date] = 0 unless ordered_earned_value[date]
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