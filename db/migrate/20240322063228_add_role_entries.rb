class AddRoleEntries < ActiveRecord::Migration[7.1]
  def change
    User::ROLES.each do |role|
      Role.find_or_create_by(name: role)
    end
  end
end
