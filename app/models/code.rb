class Code < ActiveRecord::Base
  belongs_to :location
  has_many :work_entries, :order => 'worked_at, created_at'

  scope :display_order, lambda { includes(:location).order('locations.name', 'codes.name') }

  def used?
    WorkEntry.count(:conditions => ['code_id = ?', self.id]) > 0
  end

  def full_name
    "#{code} - #{name}"
  end
end
