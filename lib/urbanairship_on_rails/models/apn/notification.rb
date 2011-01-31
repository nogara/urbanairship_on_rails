# Represents the message you wish to send. 
# An APN::Notification belongs to an APN::Device.
# 
# Example:
#   apn = APN::Notification.new
#   apn.badge = 5
#   apn.sound = 'my_sound.aiff'
#   apn.alert = 'Hello!'
#   apn.custom_properties = {:email_id => "6", :link => "http://google.com"}
#   apn.device = APN::Device.find(1)
#   apn.save
# 
# To deliver call the following method:
#   APN::Notification.process_pending
# 
# As each APN::Notification is sent the <tt>sent_at</tt> column will be timestamped,
# so as to not be sent again.
class APN::Notification < APN::Base
  include AASM
  include ::ActionView::Helpers::TextHelper
  extend ::ActionView::Helpers::TextHelper

  serialize :custom_properties
  
  has_many :excluded_devices_for_notifications, :class_name => 'APN::ExcludedDevicesForNotification'
  belongs_to :device, :class_name => 'APN::Device'

  #
  # MODEL STATE MACHINE
  #
  aasm_initial_state :pending
  aasm_column :state
  
  aasm_state :pending
  aasm_state :processed, :enter => :update_sent_at

  aasm_event :process do
    transitions :from => :pending, :to => :processed, :guard => :check_response
  end
        
  def apple_hash
    result = {}
    result['aps'] = {}
    result['aps']['alert'] = self.alert if self.alert
    result['aps']['badge'] = convert(self.badge) if self.badge
    if self.sound
      result['aps']['sound'] = self.sound if self.sound
    end
    if self.custom_properties
      self.custom_properties.each do |key,value|
        result["#{key}"] = "#{value}"
      end
    end
    result['device_tokens'] = self.device.token_for_ua
    result
  end
  
  def push
    http_post("/api/push/", apple_hash, {}, true)
  end
  
  def update_sent_at
    self.sent_at = Time.now
  end
  
  def self.process_pending
    self.pending.each do |n|
      puts "process #{n.inspect}"
      result = n.push
      n.last_response_code = result.code
      n.save
      n.process!
    end
  end
    
  def convert(input)
    if input.to_i > 0 && input.to_i.to_s == input
      return input.to_i
    else
      return input
    end
  end
  
  def check_response
    self.last_response_code == 200 ? true : false
  end
  
end # APN::Notification