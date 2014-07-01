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

      def has_time_entries_with_no_issue
        time_entries.where('issue_id IS NULL').count > 0
      end

      #Convert the by_week functions to flot.js
      def convert_to_chart(hash_with_data)
        #flot.js uses milliseconds in the date axis.
        hash_converted = Hash[hash_with_data.map{ |k, v| [k.to_time.to_i * 1000, v] }]
        #flot.js consumes arrays.
        hash_converted.to_a
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