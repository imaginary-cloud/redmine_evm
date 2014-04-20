module RedmineEvm
  module Patches
    module VersionActualCostPatch
      def self.included(base) # :nodoc:

        base.extend(ClassMethods)

        base.send(:include, VersionInstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end
    end
    module ClassMethods

      def VersionActualCostPatch.included(mod)
        puts "#{self} esta a ser incluido em #{mod}"
      end

    end

    module VersionInstanceMethods

      def get_start_date
        start_date || created_on
      end

      def end_date
        date = created_on.to_date
        fixed_issues.each do |issue|
          unless issue.time_entries.maximum('spent_on').nil?
            date = issue.time_entries.maximum('spent_on') if (issue.time_entries.maximum('spent_on') > date)
          end
        end
        date
      end

      def actual_cost
        # puts self.class
        # actual_cost = 0;
        # fixed_issues.each do |issue|
        #   unless issue.time_entries.nil?
        #     actual_cost += issue.time_entries.sum(:hours)  
        #   end
        # end
        # actual_cost
        self.spent_hours
      end

      def get_time_entries
        # time_entries = []
        # fixed_issues.each do |issue|
        #   unless issue.time_entries.nil?
        #     issue.time_entries.each do|entry|
        #       time_entries << entry  
        #     end
        #   end
        # end 
        # time_entries
        @time_entries ||= TimeEntry.joins(:issue).where("#{Issue.table_name}.fixed_version_id = ?", id)
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

unless Version.included_modules.include?(RedmineEvm::Patches::VersionActualCostPatch)
  Version.send(:include, RedmineEvm::Patches::VersionActualCostPatch)
end