class RemedyTicketsAddNccd < ActiveRecord::Migration
  def change
    change_table :remedy_tickets do |t|
      t.timestamp :next_customer_contact_date
    end
  end
end

