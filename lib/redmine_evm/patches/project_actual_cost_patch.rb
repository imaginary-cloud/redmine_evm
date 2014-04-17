module RedmineEvm
  module Patches

    module ProjectActualCostPatch

      def self.included(base) # :nodoc:

        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development  
        end

      end
    end

    module ClassMethods
      
    end

    module InstanceMethods

      def get_start_date
        start_date || created_on
      end

      def end_date
        due_date || self.baselines.find_by_state("Current").due_date
      end

      def actual_cost
        time_entries.sum(:hours)
      end

      def actual_cost_by_week
        actual_cost_by_weeks = {}
        time = 0
        unless time_entries.maximum('spent_on').nil?
          (get_start_date.to_date..time_entries.maximum('spent_on').to_date).each do |key| 
            time += time_entries.where(spent_on: key).sum(:hours)
            actual_cost_by_weeks[key.beginning_of_week] = time
          end
        end
        actual_cost_by_weeks

      end

      
    end

  end
end

unless Project.included_modules.include?(RedmineEvm::Patches::ProjectActualCostPatch)
  Project.send(:include, RedmineEvm::Patches::ProjectActualCostPatch)
end
