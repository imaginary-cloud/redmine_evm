module RedmineEvm
  module Patches
    module ProjectVersionPatch
      def self.included(base) # :nodoc:

        base.extend(ClassMethods)

        base.send(:include, ProjectVersionInstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end
    end
    module ClassMethods

    end

    module ProjectVersionInstanceMethods

      def get_start_date baseline_id
        self.instance_of?(Project) ? baselines.find(baseline_id).start_date : BaselineVersion.where(baseline_id: baseline_id, original_version_id: id).first.start_date
      end

      def get_end_date baseline_id
        issues = non_excluded_issues(baseline_id)

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

      def has_time_entries_with_no_issue
        time_entries.where('issue_id IS NULL').count > 0
      end

      #NOTE: get_start_date is not the real project start date! TODO
      def has_time_entries_before_start_date baseline_id
        time_entries.where("spent_on < '#{start_date.beginning_of_week}' ").count > 0
      end

      #Convert the by_week functions to flot.js
      def convert_to_chart(hash_with_data)
        #flot.js uses milliseconds in the date axis.
        hash_converted = Hash[hash_with_data.map{ |k, v| [k.to_time.to_i * 1000, v] }]
        #flot.js consumes arrays.
        hash_converted.to_a
      end

      # def chart_start_date baseline
      #   start_dates = []
      #   unless baseline.planned_value_by_week.first[0].nil?
      #     start_dates << baseline.planned_value_by_week.first[0]
      #   end
      #   unless self.actual_cost_by_week(baseline).first[0].nil?
      #     start_dates << self.actual_cost_by_week(baseline).first[0]
      #   end
      #   unless self.earned_value_by_week(baseline).first[0].nil?
      #     start_dates << self.earned_value_by_week(baseline).first[0]
      #   end
      #   start_dates.min
      # end

      

      private
        def non_excluded_issues baseline_id
          if self.instance_of?(Project)
            issues = self.issues.where("fixed_version_id IS NULL OR fixed_version_id NOT IN (SELECT original_version_id FROM baseline_versions WHERE exclude = true AND baseline_id = ?)", baseline_id)
          else
            issues = self.fixed_issues.where("fixed_version_id IS NULL OR fixed_version_id NOT IN (SELECT original_version_id FROM baseline_versions WHERE exclude = true AND baseline_id = ?)", baseline_id)
          end
        end

    end
  end
end

unless Project.included_modules.include?(RedmineEvm::Patches::ProjectVersionPatch)
  Project.send(:include, RedmineEvm::Patches::ProjectVersionPatch)
end
unless Version.included_modules.include?(RedmineEvm::Patches::ProjectVersionPatch)
  Version.send(:include, RedmineEvm::Patches::ProjectVersionPatch)
end