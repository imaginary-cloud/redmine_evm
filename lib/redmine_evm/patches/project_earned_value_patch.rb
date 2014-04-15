module RedmineEvm
  module Patches

    module ProjectEarnedValuePatch

      def self.included(base) # :nodoc:

        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development  
        end

      end
    end

    module ClassMethods
      
    end

    module InstanceMethods

      def earned_value
        sum_earned_value = 0.000
        issues.each do |issue|
          unless issue.estimated_hours.nil?
            sum_earned_value += issue.estimated_hours * (issue.done_ratio / 100)
          end
        end
        sum_earned_value
      end
      
    end

  end
end

unless Project.included_modules.include?(RedmineEvm::Patches::ProjectEarnedValuePatch)
  Project.send(:include, RedmineEvm::Patches::ProjectEarnedValuePatch)
end