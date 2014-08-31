class CreateRemedyTicketIssues < ActiveRecord::Migration
  def change
    create_table :remedy_ticket_issues do |t|
      t.integer :remedy_ticket_id, :null => false
      t.integer :issue_id, :null => false

      t.timestamps
    end

    add_index :remedy_ticket_issues, [ :issue_id, :remedy_ticket_id], :unique => true
    add_index :remedy_ticket_issues, :remedy_ticket_id
  end
end
