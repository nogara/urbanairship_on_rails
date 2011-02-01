class AddLastInactiveAtToDevices < ActiveRecord::Migration # :nodoc:
  def self.up
    add_column :apn_devices, :state, :string, :default => 'created', :after => :token
    add_column :apn_devices, :response_code, :string, :after => :state
    add_column :apn_devices, :response_message, :string, :after => :response_code
    add_column :apn_devices, :response_body, :text, :after => :response_message
  end

  def self.down
    remove_column :apn_devices, :state
    remove_column :apn_devices, :response_code
    remove_column :apn_devices, :response_message
    remove_column :apn_devices, :response_body
  end
end