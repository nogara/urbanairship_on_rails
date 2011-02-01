class AddLastInactiveAtToDevices < ActiveRecord::Migration # :nodoc:
  def self.up
    add_column :apn_devices, :last_inactive_at, :datetime, :after => :last_registered_at
  end

  def self.down
    remove_column :apn_devices, :last_inactive_at
  end
end