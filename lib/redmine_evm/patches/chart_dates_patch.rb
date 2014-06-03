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
          date = self.baselines.last.due_date                     #project get current baseline due_date
          issues = self.issues                                    #get all issues from this project
        else
          date = due_date || created_on.to_date                   #version due_date or created_on if not
          issues = self.fixed_issues                              #get all issues from this version
        end
    
        max_due_date_from_issues = issues.select("max(due_date) as due_date").first.due_date 
        max_spent_on_from_time_entries = issues.select("max(spent_on) as spent_on").
                                                joins("left join time_entries te on (issues.id = te.issue_id)").first.spent_on 
                                                #Left join because there are issues without time entries

        unless max_due_date_from_issues.nil?
          date = max_due_date_from_issues if max_due_date_from_issues  > date
        end
        unless max_spent_on_from_time_entries.nil?
          date = max_spent_on_from_time_entries if max_spent_on_from_time_entries > date
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