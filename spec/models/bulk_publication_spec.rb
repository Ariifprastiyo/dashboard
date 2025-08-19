require 'rails_helper'

RSpec.describe BulkPublication, type: :model do
  # it is expected to validation number of row must be greater than 0
  it { is_expected.to validate_numericality_of(:total_row).is_greater_than(0) }
end
