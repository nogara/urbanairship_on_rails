class AddCustomPropertiesOnNotifications < ActiveRecord::Migration # :nodoc:
  def self.up
    add_column :apn_notifications, :custom_properties, :text, :after => :badge
  end

  def self.down
    remove_column :apn_notifications, :custom_properties
  end
end
