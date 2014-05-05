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

      def get_time_entries
        self.instance_of?(Project) ? self.time_entries : TimeEntry.joins(:issue).where("#{Issue.table_name}.fixed_version_id = ?", id)
      end

      def actual_cost_by_week
        actual_cost_by_weeks = {}
        time = 0
        time_entries = get_time_entries
        (get_start_date.to_date..end_date.to_date).each do |key| 
          time += time_entries.select{ |date| date.spent_on == key }.sum(&:hours)
          actual_cost_by_weeks[key.beginning_of_week] = time
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