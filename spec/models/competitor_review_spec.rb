require 'rails_helper'

RSpec.describe CompetitorReview, type: :model do
  it { should belong_to(:organization).optional }
  it { should have_and_belong_to_many(:campaigns) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:organization_id) }
end
