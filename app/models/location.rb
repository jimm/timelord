class Location < ActiveRecord::Base
  has_many :codes, :dependent => :destroy

  def used?
    codes.length > 0 && WorkEntry.count(:conditions => ['code_id in (?)', self.codes.map(&:id)]) > 0
  end
end
