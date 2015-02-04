class RemedyTicket < ActiveRecord::Base
  unloadable

  attr_reader :sla_response, :sla_restore, :sla_resolve, :sla_nccd

  has_many :remedy_ticket_issues
  has_many :issues, :through => :remedy_ticket_issues

  scope :by_remedy_filter, ->(filter) {
    contract = filter.contract_number == '' ? nil : filter.contract_number
    where(:owner_group => filter.group, :contract_number => contract)
  }

  scope :open, -> { where('state < ?', 6) }
  scope :sorted, -> { order(:remedy_id) }

  SLA_OK = 0
  SLA_ACTION = 1
  SLA_WARN = 2
  SLA_OVERDUE = 3

  def contact_phone
    unless contact_country_code.nil? || contact_country_code.empty?
      "+#{contact_country_code} #{contact_local_number}"
    else
      contact_local_number
    end
  end

  def state_s
    case state
      when 0 then "New"
      when 1 then "Assigned"
      when 2 then "Re-Assigned"
      when 3 then "In Progress"
      when 4 then "Pending"
      when 5 then "Resolved"
      when 6 then "Closed"
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

  def calculate_sla
    now = Time.now
    # FIXME: configurable thresholds
    @sla_response = calculate_single_sla(actual_respond_date, target_respond_date, now, 15*60)
    @sla_restore = calculate_single_sla(actual_restore_date, target_restore_date, now, 6*60*60)
    @sla_resolve = calculate_single_sla(actual_resolve_date, target_resolve_date, now, 24*60*60)

    if state == 7
      @sla_nccd = ""
    elsif next_customer_contact_date.nil?
      @sla_nccd = "overdue"
    elsif now > next_customer_contact_date
      @sla_nccd = "warn"
    elsif now + 24*60*60 > next_customer_contact_date
      @sla_nccd = "action-required"
    else
      @sla_nccd = ""
    end
  end

  def sla_overall
    map_sla(@sla)
  end

  private

  def calculate_single_sla(actual, target, now, threshold)
    sla = SLA_OK
    unless target.nil?
      if actual.nil?
        if now > target
          sla = SLA_OVERDUE
        elsif now + threshold > target
          sla = SLA_WARN
        else
          sla = SLA_ACTION
        end
      elsif actual > target
       sla = SLA_OVERDUE
      end
    end
    @sla = sla if @sla.nil? || sla > @sla
    map_sla(sla)
  end

  def map_sla(sla)
    case sla
      when SLA_ACTION  then "action-required"
      when SLA_WARN    then "warn"
      when SLA_OVERDUE then "overdue"
      else ""
    end
  end
end
