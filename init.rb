require 'redmine_evm'

Redmine::Plugin.register :redmine_evm do
  name 'Redmine EVM plugin'
  author 'Imaginary Cloud (http://imaginarycloud.com)'
  description 'Graphical indicators for Earned Value Management'
  version '0.0.1'
  url 'https://github.com/imaginary-cloud/redmine_evm'
  author_url 'mailto:info@imaginarycloud.com'

  project_module :evm do
  	permission :evms, { :evms => [:index] }, :public => true
  end
  menu :project_menu, :evms,
       { :controller => 'evms', :action => 'index' },
       :caption => 'EVM', :after => :files
end
