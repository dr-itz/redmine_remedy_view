require File.expand_path('../../test_helper', __FILE__)

class RemedyTicketIssueTest < ActiveSupport::TestCase
  context "validations" do
    should validate_presence_of(:issue_id)
    should validate_presence_of(:remedy_ticket_id)
  end

  context "relations" do
    should belong_to(:issue)
    should belong_to(:remedy_ticket)
  end
end
