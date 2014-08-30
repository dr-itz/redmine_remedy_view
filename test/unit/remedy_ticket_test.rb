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
end
