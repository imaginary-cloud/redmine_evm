module RedmineEvm
  module Patches

    module VersionPatch
      def self.included(base) # :nodoc:

        base.extend(ClassMethods)

        base.send(:include, VersionInstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

        end
      end
    end

    module ClassMethods  
    end

    module VersionInstanceMethods

      def get_chart_data baseline
        baseline_version = baseline.baseline_versions.where(original_version_id: self.id, exclude: false).first
        chart_data = []
        unless baseline_version.nil?
          chart_data << convert_to_chart(baseline_version.planned_value_by_week)
          chart_data << convert_to_chart(self.actual_cost_by_week(baseline))
          chart_data << convert_to_chart(self.earned_value_by_week(baseline))
        end
      end

    end  
  end
end

unless Version.included_modules.include?(RedmineEvm::Patches::VersionPatch)
  Version.send(:include, RedmineEvm::Patches::VersionPatch)
end