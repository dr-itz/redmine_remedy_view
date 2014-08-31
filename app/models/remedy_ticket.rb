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

  def state_s
    case state
      when 1 then "New"
      when 2 then "Assigned"
      when 3 then "Re-Assigned"
      when 4 then "In Progress"
      when 5 then "Pending"
      when 6 then "Resolved"
      when 7 then "Closed"
      else "Unknown"
    end
  end

  def severity_s
    case severity
      when 1 then "Not Valid"
      when 2 then "Severity 1"
      when 3 then "Severity 2"
      when 4 then "Severity 3"
      when 5 then "Severity 4"
      else "Unknown"
    end
  end
end
