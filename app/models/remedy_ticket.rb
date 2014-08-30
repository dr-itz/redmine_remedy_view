class RemedyTicket < ActiveRecord::Base
  unloadable

  scope :by_remedy_filter, ->(filter) {
    where(:owner_group => filter.group, :contract_number => filter.contract_number)
  }

  scope :open, -> { where('state < ?', 6) }
  scope :sorted, -> { order(:remedy_id) }

  def contact_phone
    unless contact_country_code.nil? || contact_country_code.empty?
      "+#{contact_country_code} #{contact_local_number}"
    else
      contact_local_number
    end
  end
end
