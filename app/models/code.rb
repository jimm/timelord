class Code < ActiveRecord::Base
  belongs_to :location
  has_many :work_entries, :order => 'worked_at, created_at'

  def full_name
    "#{code} - #{name}"
  end
end
