class CreateRemedyTickets < ActiveRecord::Migration
  def change
    create_table :remedy_tickets do |t|
      t.string    :remedy_id, null: false, limit: 15
      t.timestamp :create_date
      t.timestamp :last_modified_on

      t.string    :contract_number
      t.string    :request_method, limit: 30
      t.string    :request_type, limit: 60
      t.string    :request_category, limit: 60
      t.integer   :severity
      t.integer   :state
      t.string    :state_reason, limit: 100
      t.string    :site
      t.string    :site_company
      t.string    :short_description
      t.text      :current_summary
      t.string    :customer_ticket
      t.string    :product
      t.string    :product_version
      t.string    :model

      t.string    :contact_company
      t.string    :contact_given_name
      t.string    :contact_surname
      t.string    :contact_country_code, limit: 6
      t.string    :contact_local_number, limit: 30
      t.string    :contact_email
      t.string    :additional_contact_info

      t.string    :owner_group
      t.string    :owner
      t.string    :assigned_group
      t.string    :assignee
      t.string    :last_modified_by

      t.timestamp :welcome_center_processingstart
      t.timestamp :actual_occurred_date
      t.timestamp :actual_reported_date
      t.timestamp :actual_respond_date
      t.timestamp :target_respond_date
      t.timestamp :actual_restore_date
      t.timestamp :target_restore_date
      t.timestamp :actual_resolve_date
      t.timestamp :target_resolve_date
      t.timestamp :actual_closed_date
    end

    add_index :remedy_tickets, :remedy_id
    add_index :remedy_tickets, :state
  end
end
