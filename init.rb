require 'redmine_evm'

Redmine::Plugin.register :redmine_evm do
  name 'Redmine EVM plugin'
  author 'Imaginary Cloud (http://imaginarycloud.com)'
  description 'Graphical indicators for Earned Value Management'
  version '1.0.0'
  url 'https://github.com/imaginary-cloud/redmine_evm'
  author_url 'mailto:info@imaginarycloud.com'


  project_module :evm do
  	permission :view_baselines, { :baselines => [:index, :show] }
    permission :manage_baselines, { :baselines => [:edit, :destroy, :new, :create, :update, :index]}
  end
  menu :project_menu, :baselines,
       { :controller => 'baselines', :action => 'index' },
       :caption => 'EVM', :after => :files, :param => :project_id
end
