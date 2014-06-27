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

      def get_chart_data baseline, forecast_is_enabled
        chart_data = []
        chart_data << convert_to_chart(baseline.planned_value_by_week)
        chart_data << convert_to_chart(self.actual_cost_by_week(baseline))
        chart_data << convert_to_chart(self.earned_value_by_week(baseline))
        if(forecast_is_enabled)
          chart_data << convert_to_chart(baseline.actual_cost_forecast_line)
          chart_data << convert_to_chart(baseline.earned_value_forecast_line)
          chart_data << convert_to_chart(baseline.bac_top_line)
          chart_data << convert_to_chart(baseline.eac_top_line)
        end
        chart_data
      end

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