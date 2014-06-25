module RedmineEvm
  module Patches

    module ProjectPatch
      def self.included(base) # :nodoc:

        base.extend(ClassMethods)

        base.send(:include, ProjectInstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          has_many :baselines
        end
      end
    end

    module ClassMethods  
    end

    module ProjectInstanceMethods
      def maximum_date
        maximum_start_date ||= [
        issues.maximum('start_date'),
        shared_versions.maximum('effective_date'),
        Issue.fixed_version(shared_versions).maximum('start_date')
        ].compact.max
        
        [maximum_start_date,due_date].max
      end
    end

  end
end

unless Project.included_modules.include?(RedmineEvm::Patches::ProjectPatch)
  Project.send(:include, RedmineEvm::Patches::ProjectPatch)
end