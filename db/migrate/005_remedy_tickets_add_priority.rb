class RemedyTicketsAddPriority < ActiveRecord::Migration
  def change
    change_table :remedy_tickets do |t|
      t.integer :priority
    end
  end
end

