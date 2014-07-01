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
      #still in refectoring process
      def issue_days
        dates2 = dates
        (dates2[0].to_date..dates2[1].to_date).to_a
      end
      #still in refectoring process
      def hours_per_day
        estimated_hours_for_chart / number_of_days 
      end
      #still in refectoring process
      def estimated_hours_for_chart update_hours
        update_hours ? closed? ? spent_hours : estimated_hours || 0 : estimated_hours || 0
      end

      #private #still in refectoring process
        def dates 
          dates = []
          selected_journals = journals.select {|journal| journal.journalized.done_ratio > 0}
          dates[0] = selected_journals.first.created_on unless selected_journals.first.nil?
          dates[0] = created_on if dates[0].nil?
        
          if closed?
            dates[1] = closed_on
          else
            dates[1] = updated_on
          end
          dates
        end

        def number_of_day
          issue_days.size
        end
      end  
  end
end

unless Issue.included_modules.include?(RedmineEvm::Patches::IssuePatch)
  Issue.send(:include, RedmineEvm::Patches::IssuePatch)
end