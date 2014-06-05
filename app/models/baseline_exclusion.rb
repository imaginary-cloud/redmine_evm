class BaselineExclusion < ActiveRecord::Base
  unloadable

  belongs_to :baseline
  
end