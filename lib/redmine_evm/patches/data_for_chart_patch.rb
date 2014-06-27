module RedmineEvm
  module Patches
    module DataForChartPatch
      def self.included(base) # :nodoc:

        base.extend(ClassMethods)

        base.send(:include, DataForChartInstanceMethods)

        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
        end
      end
    end

    module ClassMethods

    end

    module DataForChartInstanceMethods

      def get_chart_data baseline, forecast_is_enabled
        #Project
        if self.instance_of?(Project)
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
        #Version
        else
          baseline_version = baseline.baseline_versions.where(original_version_id: self.id, exclude: false).first
          chart_data = []
          unless baseline_version.nil?
            chart_data << convert_to_chart(baseline_version.planned_value_by_week)
            chart_data << convert_to_chart(self.actual_cost_by_week(baseline))
            chart_data << convert_to_chart(self.earned_value_by_week(baseline))
          end
        end
      end

      private 

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

unless Project.included_modules.include?(RedmineEvm::Patches::DataForChartPatch)
  Project.send(:include, RedmineEvm::Patches::DataForChartPatch)
end
unless Version.included_modules.include?(RedmineEvm::Patches::DataForChartPatch)
  Version.send(:include, RedmineEvm::Patches::DataForChartPatch)
end