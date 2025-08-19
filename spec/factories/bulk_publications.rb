FactoryBot.define do
  factory :bulk_publication do
    campaign { nil }
    total_row { 1 }
    current_row { 1 }
    error_messages { "MyString" }
  end
end
