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

      def earned_value baseline_id
        issues = get_issues baseline_id
        sum_earned_value = 0
        issues.each do |issue|
          unless issue.estimated_hours.nil?
            sum_earned_value += issue.estimated_hours * (issue.done_ratio / 100.0)
          end
        end
        sum_earned_value
      end

      def get_issues baseline_id
        if self.instance_of?(Project)
          issues_with_done_ratio = Baseline.find(baseline_id).baseline_issues.where("done_ratio = 100")   # get issues from baseline where done ratio = 100.
        else
          issues_with_done_ratio = Baseline.find(baseline_id).baseline_versions.where("original_version_id = #{self.id}").first.baseline_issues.where("done_ratio = 100")   # get issues from baseline where done ratio = 100.
        end
        oii = issues_with_done_ratio.map{ |bi| bi.original_issue_id }                                   # get only ids from baseline issues with done ratio = 100.
        
        self.instance_of?(Project) ? issues = self.issues : issues = self.fixed_issues                  # get issues from projects : versions.
        normal_issues = issues.select{ |i| i.done_ratio > 0 && oii.exclude?(i.id)  }                    # select only issues from project :versions with done ratio > 0 and ignore if its the same as baseline.
        normal_issues.each do |issue|
          #if issue.done_ratio < 100
            #if issues dont have time_entries use updated_on
            issue.time_entries.empty? ? issue.due_date = issue.updated_on.to_date : issue.due_date = issue.time_entries.maximum('spent_on')
          # else
          #   issue.due_date.nil? ? issue.due_date = issue.time_entries.maximum('spent_on') : nil
          # end         # substitui a due_date pelo maximo das time entries. 
        end
        
        unless normal_issues.nil?
          issues_with_done_ratio += normal_issues  
        end
        issues_with_done_ratio
      end

      def earned_value_by_week baseline_id
        done_ratio_by_weeks = {}
        done_ratio = 0
        earned_value = 0
        issues = get_issues baseline_id

        final_date = end_date
        date_today = Date.today
        if final_date > date_today      #If it is not a old project
          final_date = date_today
        end

        (get_start_date.to_date.beginning_of_week..final_date.to_date).each do |key| 
          unless issues.nil?
            i = issues.select {|i| i.due_date == key}
            i.each do |issue|
              unless issue.estimated_hours.nil?
                done_ratio = issue.done_ratio / 100.0
                earned_value += issue.estimated_hours * done_ratio  
              end  
            end
          end
          done_ratio_by_weeks[key.beginning_of_week] = earned_value
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