class CreateApnExcludedDevicesForNotifications < ActiveRecord::Migration # :nodoc:
  def self.up
    create_table :apn_excluded_devices_for_notifications do |t|
      t.integer :device_id
      t.integer :notification_id
      t.integer :broadcast_notification_id
      t.timestamps
    end
    add_index(:apn_excluded_devices_for_notifications, [:device_id, :notification_id], :unique => true, :name => 'by_device_notfication')
    add_index(:apn_excluded_devices_for_notifications, [:device_id, :broadcast_notification_id], :unique => true, :name => 'by_device_broadcast_notfication')
  end

  def self.down
    remove_index :apn_excluded_devices_for_notifications, :device_id
    drop_table :apn_excluded_devices_for_notifications
  end
end
