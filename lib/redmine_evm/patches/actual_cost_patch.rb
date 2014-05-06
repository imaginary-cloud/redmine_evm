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


      def actual_cost
        self.instance_of?(Project) ? time_entries.sum(:hours) : spent_hours 
      end

      def get_summed_time_entries
        if self.instance_of?(Project)
          # result = Issue.find_by_sql(['SELECT max(spent_on) as spent_on, sum(hours) as sum_hours
          #                              FROM issues i join time_entries ti on(i.id = ti.issue_id) 
          #                              WHERE i.project_id = :id group by spent_on;', id: id]).collect { |issue| [issue.spent_on, issue.sum_hours] }
          result = issues.select('MAX(spent_on) AS spent_on, SUM(hours) AS sum_hours').
                          joins('join time_entries ti ON(issues.id = ti.issue_id)').
                          group('spent_on').collect { |issue| [issue.spent_on, issue.sum_hours] }
        else
          # result = Issue.find_by_sql(['SELECT max(spent_on) as spent_on, sum(hours) as sum_hours
          #                              FROM issues i join time_entries ti on(i.id = ti.issue_id) 
          #                              WHERE i.fixed_version_id = :id group by spent_on;',id: id]).collect { |issue| [issue.spent_on, issue.sum_hours] }
          result = Issue.select('MAX(spent_on) AS spent_on, SUM(hours) AS sum_hours').
                          joins('join time_entries ti on(issues.id = ti.issue_id)').
                          where('issues.fixed_version_id = ?', id).
                          group('spent_on').collect { |issue| [issue.spent_on, issue.sum_hours] }
        end
        #sql result has class array 
        #convert array to hash
        return Hash[result] # => { 1=>2, 2=>4, 3=>6}
      end

      def get_time_entries
        self.instance_of?(Project) ? self.time_entries : TimeEntry.joins(:issue).where("#{Issue.table_name}.fixed_version_id = ?", id)
      end

      def actual_cost_by_week
        actual_cost_by_weeks = {}
        time = 0

        summed_time_entries = get_summed_time_entries

        (get_start_date.to_date..end_date.to_date).each do |key|
          unless summed_time_entries[key].nil?
            time += summed_time_entries[key]
          end
          actual_cost_by_weeks[key.beginning_of_week] = time      #time_entry to the beggining od week
        end

        actual_cost_by_weeks
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