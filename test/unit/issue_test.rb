require File.expand_path('../../test_helper', __FILE__)

class IssueTest < ActiveSupport::TestCase
  context "relations" do
    should have_many(:remedy_ticket_issues)
    should have_many(:remedy_tickets).through(:remedy_ticket_issues)
  end
end
