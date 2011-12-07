class WorkEntry < ActiveRecord::Base
  belongs_to :code

  scope :in_month, lambda { |year, month| where('substr(worked_at, 1, 4) = ? and substr(worked_at, 6, 2) = ?', year.to_s, '%02d'%month) }
end
