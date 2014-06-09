module RedmineEvm
  module Patches
    module ActualCostPatch
      def self.included(base) # :nodoc:

        base.extend(ClassMethods)

        base.send(:include, ActualCostInstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end
    end
    module ClassMethods

    end

    module ActualCostInstanceMethods

      #Filter issues if they are on a excluded version
      def get_issues_for_actual_cost baseline_id
        if self.instance_of?(Project)
          #instance of project
          issues = self.issues.where("fixed_version_id IS NULL OR fixed_version_id NOT IN (SELECT original_version_id FROM baseline_versions WHERE exclude = true AND baseline_id = ?)", baseline_id)
        else
          #instance of version
          issues = self.fixed_issues.where("fixed_version_id IS NULL OR fixed_version_id NOT IN (SELECT original_version_id FROM baseline_versions WHERE exclude = true AND baseline_id = ?)", baseline_id)
        end
      end

      def actual_cost baseline_id
        #Filter issues from excluded version.
        issues = get_issues_for_actual_cost(baseline_id) 
        
        if self.instance_of?(Project)
          result = issues.select('sum(hours) as sum_hours').joins('join time_entries ti on( issues.id = ti.issue_id)').where("spent_on BETWEEN '#{get_start_date(baseline_id).beginning_of_week}' AND '#{get_end_date(baseline_id)}'").first.sum_hours
          result.nil? ? 0 : result
        else
          spent_hours
        end
      end

      def get_summed_time_entries baseline_id
        #Filter issues from excluded version.
        issues = get_issues_for_actual_cost(baseline_id)

        if self.instance_of?(Project)
          #Project issues.
          result = issues.select('MAX(spent_on) AS spent_on, SUM(hours) AS sum_hours').
                          joins('join time_entries ti ON(issues.id = ti.issue_id)').
                          group('spent_on').collect { |issue| [issue.spent_on, issue.sum_hours] }
        else
          #Version issues.
          result = issues.select('MAX(spent_on) AS spent_on, SUM(hours) AS sum_hours').
                          joins('join time_entries ti on(issues.id = ti.issue_id)').
                          where('issues.fixed_version_id = ?', id).
                          group('spent_on').collect { |issue| [issue.spent_on, issue.sum_hours] }
        end
        #sql result has class array 
        #convert array to hash
        return Hash[result] # => { 1=>2, 2=>4, 3=>6}
      end

      def actual_cost_by_week baseline_id
        actual_cost_by_weeks = {}
        time = 0

        summed_time_entries = get_summed_time_entries(baseline_id)

        final_date = get_end_date(baseline_id)
        date_today = Date.today
        if final_date > date_today      #If it is not a old project
          final_date = date_today
        end

        (get_start_date(baseline_id).to_date.beginning_of_week..final_date.to_date).each do |key|
          unless summed_time_entries[key].nil?
            time += summed_time_entries[key]
          end
          actual_cost_by_weeks[key.beginning_of_week] = time      #time_entry to the beggining od week
        end

        actual_cost_by_weeks
      end

      def has_time_entries_with_no_issue
        time_entries.where('issue_id IS NULL').count > 0
      end

      #NOTE: get_start_date is not the real project start date! TODO
      def has_time_entries_before_start_date baseline_id
        time_entries.where("spent_on < '#{start_date.beginning_of_week}' ").count > 0
      end

    end
  end
end

unless Project.included_modules.include?(RedmineEvm::Patches::ActualCostPatch)
  Project.send(:include, RedmineEvm::Patches::ActualCostPatch)
end
unless Version.included_modules.include?(RedmineEvm::Patches::ActualCostPatch)
  Version.send(:include, RedmineEvm::Patches::ActualCostPatch)
end