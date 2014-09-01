require_dependency 'issue'

class Issue
  has_many :remedy_ticket_issues
  has_many :remedy_tickets, :through => :remedy_ticket_issues
end
