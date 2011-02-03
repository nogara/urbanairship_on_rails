class APN::ExcludedDevicesForNotification < APN::Base

  belongs_to :broadcast_notification, :class_name => 'APN::BroadcastNotification'
  belongs_to :notification, :class_name => 'APN::Notification'
  belongs_to :device, :class_name => 'APN::Device'
  
  validates_presence_of :device, :on => :create, :message => "is required"
  validates_presence_of :notification, :on => :create, :message => "or BroadcastNotification is required", :unless => :has_broadcast_notification?

  validates_uniqueness_of :notification_id, :scope => :device_id, :allow_nil => true
  validates_uniqueness_of :broadcast_notification_id, :scope => :device_id, :allow_nil => true
  
  named_scope :broadcasts, lambda { 
      { :conditions => "broadcast_notification_id IS NOT NULL" }
    }  
  
  
  def has_broadcast_notification?
    broadcast_notification.nil? ? false : true
  end
end