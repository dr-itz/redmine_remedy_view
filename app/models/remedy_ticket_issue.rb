class RemedyTicketIssue < ActiveRecord::Base
  unloadable

  belongs_to :issue
  belongs_to :remedy_ticket
  belongs_to :project

  validates :remedy_ticket_id, :presence => true
  validates :project_id,       :presence => true

  validates :issue_id,         :uniqueness => { :scope => :remedy_ticket_id  }
end
