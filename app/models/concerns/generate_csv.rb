# frozen_string_literal: true

module GenerateCsv
  extend ActiveSupport::Concern
  require 'csv'

  # this will behave like ActiveRecord extension
  # we can do something like User.active.to_csv
  # or Campaign.active.to_csv
  included do
    def self.to_csv
      CSV.generate do |csv|
        csv << column_names
        all.each do |record|
          csv << record.attributes.values
        end
      end
    end
  end
end
