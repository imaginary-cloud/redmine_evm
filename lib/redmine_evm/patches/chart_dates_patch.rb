module RedmineEvm
  module Patches
    module ChartDatesPatch
      def self.included(base) # :nodoc:

        base.extend(ClassMethods)

        base.send(:include, ChartDatesInstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end
    end
    module ClassMethods

    end

    module ChartDatesInstanceMethods

      def get_start_date
        start_date || created_on
      end

      def end_date
        if self.instance_of?(Project)
          date = self.baselines.find_by_state("Current").due_date
          issues = self.issues
        else
          date = due_date || created_on.to_date 
          issues = self.fixed_issues
        end

        issues.each do |issue|
          unless issue.due_date.nil?
            date = issue.due_date if issue.due_date > date
          end
          unless issue.time_entries.maximum('spent_on').nil?
            date = issue.time_entries.maximum('spent_on') if (issue.time_entries.maximum('spent_on') > date)
          end
        end

        date
      end

    end
  end
end

unless Project.included_modules.include?(RedmineEvm::Patches::ChartDatesPatch)
  Project.send(:include, RedmineEvm::Patches::ChartDatesPatch)
end
unless Version.included_modules.include?(RedmineEvm::Patches::ChartDatesPatch)
  Version.send(:include, RedmineEvm::Patches::ChartDatesPatch)
end