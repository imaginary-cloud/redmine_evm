Redmine::Plugin.register :redmine_evm do
	
  name 'Redmine Evm plugin'
  author 'ImaginaryCloud'
  description 'Graphical indicators for EV Management'
  version '0.9.0'
  url 'http://imaginarycloud.com'
  author_url 'mailto:jcosta@imaginarycloud.com'

  permission :ratios, { :ratios => [:index] }, :public => true
  menu :project_menu, :ratios, { :controller => 'ratios', :action => 'index' }, :caption => 'EVM', :after => :files


end
