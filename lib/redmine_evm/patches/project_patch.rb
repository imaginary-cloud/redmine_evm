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
        issues.where("issues.id NOT IN (SELECT original_issue_id as id FROM baseline_issues WHERE exclude = 1 AND baseline_id = ?)", baseline_id)
      end

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

      def defacto_start_date_for_baseline(baseline)
        self.filter_excluded_issues(baseline).minimum(:start_date) || self.start_date
      end

      def actual_cost_by_week baseline
        actual_cost_by_weeks = {}
        time = 0
        start_date = self.defacto_start_date_for_baseline(baseline)
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
        baselines.find(baseline_id).update_hours ? update_hours = true : update_hours = false
        relevant_issues = issues.reject do |issue|
          issue.baseline_issues.find_by_baseline_id(baseline_id).try(:exclude)  || issue.baseline_issues.find_by_baseline_id(baseline_id).nil? || !issue.leaf?
        end
        relevant_issues.each do |issue|
          issue.days.each do |day|
            earned_value_by_week[day] += issue.hours_per_day(update_hours, baseline_id) * issue.done_ratio/100.0
          end
        end
        ordered_earned_value = order_earned_value earned_value_by_week
        extend_earned_value_to_final_date ordered_earned_value, baseline_id
      end

      def earned_value baseline_id
        sum_earned_value = 0
        relevant_issues = issues.reject do |issue|
          issue.baseline_issues.where(original_issue_id: issue.id, baseline_id: baseline_id).first.try(:exclude) || issue.baseline_issues.find_by_baseline_id(baseline_id).nil? || !issue.leaf?
        end

        relevant_issues.each do |issue|
          if baselines.find(baseline_id).update_hours && issue.closed?
            next if issue.spent_hours == 0
            sum_earned_value += issue.spent_hours * (issue.done_ratio / 100.0)
          else
            next if issue.estimated_hours.nil?
            sum_earned_value += issue.estimated_hours * (issue.done_ratio / 100.0)
          end
        end
        sum_earned_value
      end

      def data_for_chart baseline, forecast_is_enabled
        chart_data = {}
        chart_data['planned_value'] = convert_to_chart(baseline.planned_value_by_week)
        chart_data['actual_cost']   = convert_to_chart(self.actual_cost_by_week(baseline))
        chart_data['earned_value']  = convert_to_chart(self.earned_value_by_week(baseline))

        if(forecast_is_enabled)
          chart_data['actual_cost_forecast']  = convert_to_chart(baseline.actual_cost_forecast_line)
          chart_data['earned_value_forecast'] = convert_to_chart(baseline.earned_value_forecast_line)
          chart_data['bac_top_line']          = convert_to_chart(baseline.bac_top_line)
          chart_data['eac_top_line']          = convert_to_chart(baseline.eac_top_line)
        end
        chart_data #Data ready for chart flot.js to consume.
      end

      def maximum_chart_date baseline
        issues = filter_excluded_issues(baseline)

        dates = []
        dates << baseline.due_date # planned value line
        dates << issues.select("max(spent_on) as spent_on").joins(:time_entries).first.spent_on # actual cost line
        dates << issues.map(&:updated_on).compact.max.try(:to_date)
        dates << issues.map(&:closed_on).compact.max.try(:to_date)

        dates << defacto_start_date_for_baseline(baseline) #If there is no data yet

        dates.compact.max
        #dates.max.nil? ? 0 : dates.max
      end

      def maximum_date
        maximum_start_date = [
          issues.maximum('start_date'),
          shared_versions.maximum('effective_date'),
          Issue.fixed_version(shared_versions).maximum('start_date')
          ].compact.max

        [maximum_start_date, due_date].compact.max
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
          if Date.today < baselines.find(baseline_id).due_date
            dat = Date.today
          else
            dat = baselines.find(baseline_id).due_date
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

unless Project.included_modules.include?(RedmineEvm::Patches::ProjectPatch)
  Project.send(:include, RedmineEvm::Patches::ProjectPatch)
end