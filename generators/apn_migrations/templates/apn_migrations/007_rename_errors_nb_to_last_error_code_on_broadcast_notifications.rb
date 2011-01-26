class RenameErrorsNbToLastErrorCodeOnBroadcastNotifications < ActiveRecord::Migration # :nodoc:
  
  def self.up
      rename_column :apn_broadcast_notifications, :errors_nb, :last_response_code
  end

  def self.down
      rename_column :apn_broadcast_notifications, :last_response_code, :errors_nb
  end
  
end