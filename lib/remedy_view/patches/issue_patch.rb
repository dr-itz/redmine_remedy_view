require_dependency 'issue'

class Issue
  has_many :remedy_ticket_issues
  has_many :remedy_tickets, :through => :remedy_ticket_issues

  accepts_nested_attributes_for :remedy_ticket_issues
  safe_attributes 'remedy_ticket_issues_attributes'
end
