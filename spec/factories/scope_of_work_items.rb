FactoryBot.define do
  factory :scope_of_work_item do
    scope_of_work { nil }
    name { "story" }
    quantity { 1 }
    price { "9.99" }
    subtotal { "9.99" }
  end
end
