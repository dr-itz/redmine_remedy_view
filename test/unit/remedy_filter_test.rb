require File.expand_path('../../test_helper', __FILE__)

class RemedyFilterTest < ActiveSupport::TestCase
  context "validations" do
    should validate_presence_of(:project_id)
    should validate_presence_of(:title)
    should validate_presence_of(:group)
#    should validate_presence_of(:contract_number)

    should validate_uniqueness_of(:title).scoped_to(:project_id)
    should validate_uniqueness_of(:contract_number).scoped_to(:project_id, :group)
  end
end
