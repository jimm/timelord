class Location < ActiveRecord::Base
  has_many :codes, :dependent => :destroy
end
