require File.expand_path('../../test_helper', __FILE__)

class RemedyTicketTest < ActiveSupport::TestCase
  plugin_fixtures :remedy_tickets

  test "phone number with prefix" do
    t = RemedyTicket.find(1)
    assert_equal "+41 44 123 45 67", t.contact_phone
  end

  test "phone number without prefix" do
    t = RemedyTicket.find(2)
    assert_equal "44 123 45 67", t.contact_phone
  end

  test "state mapping" do
    t = RemedyTicket.find(1)

    t.state = 1
    assert_equal "New", t.state_s
    t.state = 2
    assert_equal "Assigned", t.state_s
    t.state = 3
    assert_equal "Re-Assigned", t.state_s
    t.state = 4
    assert_equal "In Progress", t.state_s
    t.state = 5
    assert_equal "Pending", t.state_s
    t.state = 6
    assert_equal "Resolved", t.state_s
    t.state = 7
    assert_equal "Closed", t.state_s
    t.state = 0
    assert_equal "Unknown", t.state_s
  end

  test "severity mapping" do
    t = RemedyTicket.find(1)

    t.severity = 1
    assert_equal "Not Valid", t.severity_s
    t.severity = 2
    assert_equal "Severity 1", t.severity_s
    t.severity = 3
    assert_equal "Severity 2", t.severity_s
    t.severity = 4
    assert_equal "Severity 3", t.severity_s
    t.severity = 5
    assert_equal "Severity 4", t.severity_s
    t.severity = 77
    assert_equal "Unknown", t.severity_s
  end
end
