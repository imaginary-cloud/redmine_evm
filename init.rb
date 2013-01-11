Redmine::Plugin.register :redmine_evm do
  name 'Redmine EVM plugin'
  author 'Imaginary Cloud (http://imaginarycloud.com)'
  description 'Graphical indicators for Earned Value Management'
  version '0.9.0'
  url 'https://github.com/imaginary-cloud/redmine_evm'
  author_url 'mailto:info@imaginarycloud.com'

  project_module :evm do
    permission :ratios, { :ratios => [:index] }, :public => true
  end
  menu :project_menu, :ratios,
       { :controller => 'ratios', :action => 'index' },
       :caption => 'EVM', :after => :files
end
