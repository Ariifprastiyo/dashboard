require 'rails_helper'

RSpec.describe Brand, type: :model do
  it { is_expected.to have_many(:campaigns).dependent(:destroy) }
  it { is_expected.to belong_to(:organization).optional }
end
