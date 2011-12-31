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

class APN::Notification < APN::Base
  include AASM
  include ::ActionView::Helpers::TextHelper
  extend ::ActionView::Helpers::TextHelper

  serialize :custom_properties
  
  has_many :excluded_devices, :class_name => 'APN::ExcludedDevicesForNotification'
  belongs_to :device, :class_name => 'APN::Device'
  
  validates_presence_of :device, :on => :create, :message => "can't be blank"
  validate :device_state :on => :create

  #
  # MODEL STATE MACHINE
  #
  aasm_initial_state :pending
  aasm_column :state
  
  aasm_state :pending
  aasm_state :processed, :enter => :update_sent_at
  aasm_state :inactive_device

  aasm_event :process do
    transitions :from => :pending, :to => :processed, :guard => :check_response
  end

  aasm_event :set_to_inactive do
    transitions :from => :pending, :to => :inactive_device
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
    puts "process #{self.inspect}"
    result = http_post("/api/push/", apple_hash, {}, true)
    self.last_response_code = result.code
    self.save
    self.process!
  end
  
  def update_sent_at
    self.sent_at = Time.now
  end
  
  def self.process_pending
    self.pending.each do |n|
      unless n.device.inactive?
        n.push
      end
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
  
  def device_state
    errors.add(:device, "must not be marked as inactive") if device.inactive?
  end
  
end # APN::Notification
