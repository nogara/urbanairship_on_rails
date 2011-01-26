class ChangeBadgeToStringOnNotifications < ActiveRecord::Migration # :nodoc:
  
  def self.up
      change_column :apn_notifications, :badge, :string
  end

  def self.down
      change_column :apn_notifications, :badge, :integer
  end
  
end