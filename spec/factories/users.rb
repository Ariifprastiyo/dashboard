FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@mail.com" }
    password { "MyString" }

    factory :admin do
      name { "Admin" }

      after(:create) do |user|
        user.add_role :admin
      end
    end

    factory :super_admin do
      name { "Super Admin" }

      after(:create) do |user|
        user.add_role :super_admin
      end
    end

    factory :spectator do
      name { "Spectator" }

      after(:create) do |user|
        user.add_role :spectator
      end
    end
  end
end
