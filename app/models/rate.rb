class Rate < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable

  belongs_to :user
  belongs_to :project

  attr_accessible :rate
  acts_as_customizable

  safe_attributes 'rate'
end