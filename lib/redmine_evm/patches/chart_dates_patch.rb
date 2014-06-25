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

      def get_start_date baseline_id
        issues = get_non_excluded_issues(baseline_id)
        date = issues.minimum(:start_date) || created_on
      end

      def get_end_date baseline_id
        issues = get_non_excluded_issues(baseline_id)

        date = Baseline.find(baseline_id).due_date if self.instance_of?(Project)
        date = due_date || created_on.to_date unless self.instance_of?(Project)
    
        max_due_date_from_issues = issues.maximum(:due_date)
        max_spent_on_from_time_entries = issues.select("max(spent_on) as spent_on").
                                                joins("left join time_entries te on (issues.id = te.issue_id)").first.spent_on 
                                                #Left join because there are issues without time entries
        
        date = max_due_date_from_issues if max_due_date_from_issues > date unless max_due_date_from_issues.nil?
        date = max_spent_on_from_time_entries if max_spent_on_from_time_entries > date unless max_spent_on_from_time_entries.nil?

        date
      end

      private
        def get_non_excluded_issues baseline_id
          if self.instance_of?(Project)
            issues = self.issues.where("fixed_version_id IS NULL OR fixed_version_id NOT IN (SELECT original_version_id FROM baseline_versions WHERE exclude = true AND baseline_id = ?)", baseline_id)
          else
            issues = self.fixed_issues.where("fixed_version_id IS NULL OR fixed_version_id NOT IN (SELECT original_version_id FROM baseline_versions WHERE exclude = true AND baseline_id = ?)", baseline_id)
          end
        end

        def get_non_exluded_versions baseline_id
          if self.instance_of?(Project)
            versions = self.versions.where("id NOT IN (SELECT original_version_id FROM baseline_versions WHERE exclude = true AND baseline_id = ?)", baseline_id)
          else
            versions = self.fixed_issues.where("fixed_version_id IS NULL OR fixed_version_id NOT IN (SELECT original_version_id FROM baseline_versions WHERE exclude = true AND baseline_id = ?)", baseline_id)
          end
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