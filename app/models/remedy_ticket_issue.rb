class RemedyTicketIssue < ActiveRecord::Base
  unloadable

  belongs_to :issue
  belongs_to :remedy_ticket

  validates :issue_id,         :presence => true
  validates :remedy_ticket_id, :presence => true

  validates :issue_id,         :uniqueness => { :scope => :remedy_ticket_id  }
end
