class CreateRemedyFilters < ActiveRecord::Migration
  def change
    create_table :remedy_filters do |t|
      t.integer   :project_id,       :default => 0,     :null => false
      t.string    :title
      t.string    :group
      t.string    :contract_number
    end
    add_index "remedy_filters", ["project_id"]
  end
end
