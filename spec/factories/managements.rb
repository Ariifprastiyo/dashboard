FactoryBot.define do
  factory :management do
    name { "MyString" }
    phone { "MyString" }
    no_ktp { "MyString" }
    no_npwp { "MyString" }
    bank_code { "MyString" }
    account_number { "MyString" }
    address { "MyString" }

    factory :management_with_accounts do
      name { "Bless" }

      transient do
        social_media_accounts { [] }
      end

      after(:create) do |management, evaluator|
        evaluator.social_media_accounts.each do |social_media_account|
          management.social_media_accounts << social_media_account
        end
      end
    end
  end
end
