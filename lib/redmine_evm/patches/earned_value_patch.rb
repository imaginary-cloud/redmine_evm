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

      def get_issues_for_earned_value baseline_id

        #Get issues that are not excluded. from chart_dates_patch
        issues = get_non_excluded_issues(baseline_id)

        #Get baseline issues whre status is closed(completed issues).
        if self.instance_of?(Project)
          issues_with_done_ratio = Baseline.find(baseline_id).baseline_issues.where(status: "Closed", exclude: false)   
        else
          issues_with_done_ratio = Baseline.find(baseline_id).baseline_versions.where("original_version_id = #{self.id}").first.baseline_issues.where(status: "Closed", exclude: false) 
        end

        #coloca due dates 
        issues_with_done_ratio.each do |baseline_issue|
          unless baseline_issue.due_date.nil?
            if issues.where("id = #{baseline_issue.original_issue_id}").first.time_entries.empty?
              baseline_issue.due_date = issues.where("id = #{baseline_issue.original_issue_id}").first.updated_on.to_date
            else
              baseline_issue.due_date = issues.where("id = #{baseline_issue.original_issue_id}").first.time_entries.maximum('spent_on')
            end
          end
        end

        oii = issues_with_done_ratio.map(&:original_issue_id)                                 
        
        normal_issues = issues.select{ |i| i.done_ratio > 0 && oii.exclude?(i.id)  }                    # select only issues from project :versions with done ratio > 0 and ignore if its the same as baseline.
        normal_issues.each do |issue|
            issue.time_entries.empty? ? issue.due_date = issue.updated_on.to_date : issue.due_date = issue.time_entries.maximum('spent_on')
        end
        
        unless normal_issues.nil?
          issues_with_done_ratio += normal_issues  
        end
        issues_with_done_ratio
      end

      #  def earned_value baseline_id
      #   exluded_issues = BaselineIssue.where(:baseline_id => 93, :exclude => true)
      #   #issues.reject{|issue| issue.fixed_version.nil?} #rever a situação das exluded issues
      #   sum_earned_value = 0
      #   issues.each do |issue|
      #     next if exluded_issues.include?(:original_issue_id => issue.id)
      #     unless issue.estimated_hours.nil?
      #       sum_earned_value += issue.estimated_hours * (issue.done_ratio / 100.0)
      #     end
      #   end
      #   sum_earned_value
      # end

      # def earned_value baseline_id
      #   issues = get_issues_for_earned_value(baseline_id)
      #   sum_earned_value = 0
      #   issues.each do |issue|
      #     unless issue.estimated_hours.nil?
      #       sum_earned_value += issue.estimated_hours * (issue.done_ratio / 100.0)
      #     end
      #   end
      #   sum_earned_value
      # end

      # def earned_value_by_week baseline_id
      #   # journals = issue.journals.select {|journal| journal.journalized.done_ratio > 0}


      #   earned_value_by_week = {}
      #     (start_date.beginning_of_week..get_end_date(baseline_id)).each do |date|
      #   earned_value_by_week[date.beginning_of_week] = 0
      #   end

      #   issues = get_non_excluded_issues(baseline_id)

      #   issues.each do |issue|
      #     issue_dates = get_issues_dates issue
      #     issue.estimated_hours = BaselineIssue.where(:original_issue_id => issue.id, :baseline_id => baseline_id).first.estimated_hours if issue.closed? && !BaselineIssue.where(:original_issue_id => issue.id, :baseline_id => baseline_id).first.nil?
      #     unless issue.estimated_hours.nil?
      #     # issue_days = (issue.start_date..issue.due_date).to_a
      
      #     issues_days = (issue_dates[0].to_date..issue_dates[1].to_date).to_a
      #     hoursPerDay = issue.estimated_hours / issues_days.size 
            
          
        
      #     issues_days.each do |day|
      #       earned_value_by_week[day.beginning_of_week] += hoursPerDay * issue.done_ratio/100.0 unless earned_value_by_week[day.beginning_of_week].nil?
      #     end
      #     end
      #   end
      #   earned_value_by_week.each_with_object({}) { |(k, v), h| h[k] = v + (h.values.last||0)  }
      # end

      def get_issues_dates issue
        issue_dates = []
        if !issue.start_date.nil?
          issue_dates[0]= issue.start_date
        elsif !issue.fixed_version.start_date.nil?
          issue_dates[0]= issue.fixed_version.start_date
        else
          issue_dates[0]= issue.fixed_version.created_on
        end

        if !issue.due_date.nil?
          issue_dates[1]= issue.due_date
        elsif !issue.fixed_version.nil?
          issue_dates[1]= issue.fixed_version.due_date if !issue.fixed_version.due_date.nil?
          issue_dates[1]= issue.updated_on if issue.fixed_version.due_date.nil? 
        else
          issue_dates[1]= issue.updated_on
        end
        issue_dates
      end

      # def earned_value_by_week baseline_id
      #   done_ratio_by_weeks = {}
      #   done_ratio = 0
      #   earned_value = 0
      #   issues = get_issues_for_earned_value(baseline_id)

      #   final_date = get_end_date(baseline_id)
      #   date_today = Date.today
      #   if final_date > date_today      #If it is not a old project
      #     final_date = date_today
      #   end

      #   (get_start_date(baseline_id).to_date.beginning_of_week..final_date.to_date).each do |key| 
      #     unless issues.nil?
      #       i = issues.select {|i| i.due_date == key}
      #       i.each do |issue|
      #         unless issue.estimated_hours.nil?
      #           done_ratio = issue.done_ratio / 100.0
      #           earned_value += issue.estimated_hours * done_ratio  
      #         end  
      #       end
      #     end
      #     done_ratio_by_weeks[key.beginning_of_week] = earned_value
      #   end
      #   done_ratio_by_weeks
      # end
 
    end
  end
end

unless Project.included_modules.include?(RedmineEvm::Patches::EarnedValuePatch)
  Project.send(:include, RedmineEvm::Patches::EarnedValuePatch)
end
unless Version.included_modules.include?(RedmineEvm::Patches::EarnedValuePatch)
  Version.send(:include, RedmineEvm::Patches::EarnedValuePatch)
end