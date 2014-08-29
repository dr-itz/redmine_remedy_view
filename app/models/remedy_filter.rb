class RemedyFilter < ActiveRecord::Base
  unloadable

  belongs_to :project

  validates :project_id,      :presence => true
  validates :title,           :presence => true
  validates :group,           :presence => true
  validates :contract_number, :presence => true

  validates_uniqueness_of :title,           :scope => [ :project_id ]
  validates_uniqueness_of :contract_number, :scope => [ :project_id, :group ]

  scope :project_filters, lambda { |project|
    where(:project_id => project.is_a?(Project) ? project.id : project)
    .order('title')
  }
end
