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

      def get_issues_for_dates baseline_id
        if self.instance_of?(Project)
          #instance of project
          issues = self.issues.where("fixed_version_id IS NULL OR fixed_version_id NOT IN (SELECT version_id FROM baseline_exclusions WHERE baseline_id = ?)", baseline_id)
        else
          #instance of version
          issues = self.fixed_issues.where("fixed_version_id IS NULL OR fixed_version_id NOT IN (SELECT version_id FROM baseline_exclusions WHERE baseline_id = ?)", baseline_id)
        end
      end

      def get_start_date baseline_id
        #Filter issues from excluded version.
        issues = get_issues_for_dates(baseline_id)

        #start_date || created_on
        date = issues.minimum(:start_date) || created_on
      end

      def get_end_date baseline_id
        #Filter issues from excluded version.
        issues = get_issues_for_dates(baseline_id)

        if self.instance_of?(Project)
          date = Baseline.find(baseline_id).due_date #project get current baseline due_date
          issues = self.issues                                    #get all issues from this project
        else
          date = due_date || created_on.to_date                   #version due_date or created_on if not
          issues = self.fixed_issues                              #get all issues from this version
        end
    
        max_due_date_from_issues = issues.maximum(:due_date)
        max_spent_on_from_time_entries = issues.select("max(spent_on) as spent_on").
                                                joins("left join time_entries te on (issues.id = te.issue_id)").first.spent_on 
                                                #Left join because there are issues without time entries

        unless max_due_date_from_issues.nil?
          date = max_due_date_from_issues if max_due_date_from_issues > date
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