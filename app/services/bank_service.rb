# frozen_string_literal: true

class BankService
  csv_file = File.read(Rails.root.join('lib', 'seeds', 'banks.csv'))

  LIST = CSV.parse(csv_file).map { |x| { x[0] => x[1] } }.reduce({}, :merge).with_indifferent_access.freeze
end
