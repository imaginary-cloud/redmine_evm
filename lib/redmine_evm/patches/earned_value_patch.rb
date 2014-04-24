  module RedmineEvm
  module Patches

    module EarnedValuePatch

      def self.included(base) # :nodoc:

        base.extend(ClassMethods)

        base.send(:include, EarnedValueInstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development  
        end

      end
    end

    module ClassMethods
      
    end

    module EarnedValueInstanceMethods

      def earned_value
        self.instance_of?(Project) ? issues = self.issues : issues = fixed_issues

        sum_earned_value = 0
        issues.each do |issue|
          unless issue.estimated_hours.nil?
            sum_earned_value += issue.estimated_hours * (issue.done_ratio / 100.0)
          end
        end
        sum_earned_value
      end

      def get_issues
        issues = self.instance_of?(Project) ? Issue.joins(:time_entries).order(:spent_on).where("#{Issue.table_name}.project_id = :id" , id: id).uniq : Issue.joins(:time_entries).where("fixed_version_id = :id" , id: id).uniq 
        issues.sort_by{ |issue| issue.time_entries.maximum('spent_on') }
      end

      def earned_value_by_week
        done_ratio_by_weeks = {}
        done_ratio = 0
        earned_value = 0
      
        sorted_issues = get_issues

        sorted_issues.each do |issue|
          done_ratio = issue.done_ratio / 100.0
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

unless Project.included_modules.include?(RedmineEvm::Patches::EarnedValuePatch)
  Project.send(:include, RedmineEvm::Patches::EarnedValuePatch)
end
unless Version.included_modules.include?(RedmineEvm::Patches::EarnedValuePatch)
  Version.send(:include, RedmineEvm::Patches::EarnedValuePatch)
end