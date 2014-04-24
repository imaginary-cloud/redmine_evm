module RedmineEvm
  module Patches
    module ProjectsHelperPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable

          alias_method_chain :project_settings_tabs, :baselines
        end
      end

      module InstanceMethods
        def project_settings_tabs_with_baselines
          tabs = project_settings_tabs_without_baselines

          tabs.push({ :name => 'baselines',
                      :action => :view_baselines,
                      :partial => 'projects/baselines_settings',
                      :label => :label_baseline_plural})

          tabs
        end
      end
    end
  end
end

unless ProjectsHelper.included_modules.include?(RedmineEvm::Patches::ProjectsHelperPatch)
  ProjectsHelper.send(:include, RedmineEvm::Patches::ProjectsHelperPatch)
end
