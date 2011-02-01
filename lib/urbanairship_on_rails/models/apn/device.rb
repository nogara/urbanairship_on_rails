# Represents an iPhone (or other APN enabled device).
# An APN::Device can have many APN::Notification.
# 
# In order for the APN::Feedback system to work properly you *MUST*
# touch the <tt>last_registered_at</tt> column everytime someone opens
# your application. If you do not, then it is possible, and probably likely,
# that their device will be removed and will no longer receive notifications.
# 
# Example:
#   Device.create(:token => '5gxadhy6 6zmtxfl6 5zpbcxmw ez3w7ksf qscpr55t trknkzap 7yyt45sc g6jrw7qz')
class APN::Device < APN::Base
  include AASM

  before_destroy :unregister, :destroy_undelivered_notifications, :destroy_undelivered_broadcast_exclusions
  # before_save :set_last_registered_at

  belongs_to :user, :dependent => :delete
  has_many :notifications, :class_name => 'APN::Notification'
  has_many :exclusions_from_notifications, :class_name => 'APN::ExcludedDevicesForNotification'

  validates_presence_of :token
  validates_uniqueness_of :token
  validates_format_of :token, :with => /^[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}\s[a-z0-9]{8}$/

  # The <tt>feedback_at</tt> accessor is set when the 
  # device is marked as potentially disconnected from your
  # application by Apple.
  attr_accessor :feedback_at
  
  aasm_initial_state :created
  aasm_column :state
  
  aasm_state :created
  aasm_state :activated, :enter => :set_last_registered_at
  aasm_state :inactive, :enter => :set_last_inactive_at

  aasm_event :activate do
    transitions :from => [:created, :inactive, :activated], :to => :activated, :guard => :check_response
  end
  
  aasm_event :deactivate do
    transitions :from => [:created, :inactive, :activated], :to => :inactive
  end  
  
  # Stores the token (Apple's device ID) of the iPhone (device).
  # 
  # If the token comes in like this:
  #  '<5gxadhy6 6zmtxfl6 5zpbcxmw ez3w7ksf qscpr55t trknkzap 7yyt45sc g6jrw7qz>'
  # Then the '<' and '>' will be stripped off.
  
  def token=(token)
    res = token.scan(/\<(.+)\>/).first
    unless res.nil? || res.empty?
      token = res.first
    end
    write_attribute('token', token)
  end

  def register(options=nil)
    puts "APN::Device.register"
    # options = options.merge({:alias => self.user.id}) if self.user
    result = http_put("/api/device_tokens/#{self.token_for_ua}", options)
    self.response_code = result.code.to_s
    self.response_message = result.message.to_s
    self.response_body = result.body.to_s
    self.save
    self.activate!
  end
    
  # You can read a device token’s alias with an HTTP GET to /api/device_tokens/<device_token>, which returns application/json:
  # {"device_token": "some device token","alias": "your_user_id"}
  def read
    puts "APN::Device.read"
    http_get("/api/device_tokens/#{self.token_for_ua}")
  end
  
  # The DELETE returns HTTP 204 No Content, and needs no payload.
  # When a token is DELETEd in this manner, any alias or tags will be cleared.
  
  def token_for_ua
    self.token.gsub(' ', '').upcase
  end
  
  def self.find_by_ua_token(ua_token)
    find_by_token(ua_token.downcase.scan(/.{8}/).join(" "))
  end

  private
  
  def unregister
    puts "APN::Device.unregister"
    http_delete("/api/device_tokens/#{self.token_for_ua}")
  end
  
  def destroy_undelivered_notifications
    self.notifications.pending.each do |notification|
      notification.excluded_devices.first.destroy unless notification.excluded_devices.first.nil?
      notification.destroy
    end
  end

  def destroy_undelivered_broadcast_exclusions
    self.exclusions_from_notifications.broadcasts.each do |exclusion|
      unless exclusion.broadcast_notification.nil?
        exclusion.destroy unless exclusion.broadcast_notification.processed?
      end
    end
  end

  def set_last_registered_at
    self.last_registered_at = Time.now
  end

  def set_last_inactive_at
    self.last_inactive_at = Time.now
  end

  def check_response
    if self.response_code == "200" || self.response_code == "201"
      return true
    else
      self.deactivate!
      return false
    end
  end
end