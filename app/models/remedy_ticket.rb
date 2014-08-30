class RemedyTicket < ActiveRecord::Base
  unloadable

  scope :by_remedy_filter, ->(filter) {
    where(:owner_group => filter.group, :contract_number => filter.contract_number)
  }

  scope :open, -> { where('state < ?', 6) }
  scope :sorted, -> { order(:remedy_id) }
end
