module RedmineEvm
  module Patches

    module ProjectEarnedValuePatch

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

      def earned_value
        sum_earned_value = 0
        issues.each do |issue|
          unless issue.estimated_hours.nil?
            sum_earned_value += issue.estimated_hours * (issue.done_ratio / 100.0)
          end
        end
        sum_earned_value
      end

      def earned_value_by_week
        done_ratio_by_weeks = {}
        done_ratio = 0
        earned_value = 0
        filtered_issues = issues.select{ |i| !i.time_entries.maximum('spent_on').nil? }
        sorted_issues = filtered_issues.sort_by{ |issue| issue.time_entries.maximum('spent_on') }
        
        sorted_issues.each do |issue|
          done_ratio = issue.done_ratio / 100
          unless issue.time_entries.maximum('spent_on').nil?
            date = issue.time_entries.maximum('spent_on').to_date
            unless issue.estimated_hours.nil?
              earned_value += issue.estimated_hours * done_ratio
            end
            done_ratio_by_weeks[date.beginning_of_week] = earned_value
          end
        end
        done_ratio_by_weeks
      end

      
    end

  end
end

unless Project.included_modules.include?(RedmineEvm::Patches::ProjectEarnedValuePatch)
  Project.send(:include, RedmineEvm::Patches::ProjectEarnedValuePatch)
end