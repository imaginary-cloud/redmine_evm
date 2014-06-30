module RedmineEvm
  module Patches

    module IssuePatch
      def self.included(base) # :nodoc:

        base.extend(ClassMethods)

        base.send(:include, IssueInstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          has_many :baseline_issues, :foreign_key => 'original_issue_id'
        end
      end
    end

    module ClassMethods  
    end

    module IssueInstanceMethods
      def dates 
        dates = []
        selected_journals = journals.select {|journal| journal.journalized.done_ratio > 0}
        dates[0] = selected_journals.first.created_on unless journals.empty?
        dates[0] = created_on if selected_journals.nil?
        
        if closed?
          dates[1] = closed_on
        else
          dates[1] = updated_on
        end
        dates
      end
    end  
  end
end

unless Issue.included_modules.include?(RedmineEvm::Patches::IssuePatch)
  Issue.send(:include, RedmineEvm::Patches::IssuePatch)
end