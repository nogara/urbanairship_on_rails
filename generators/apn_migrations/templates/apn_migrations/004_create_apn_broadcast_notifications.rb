class CreateApnBroadcastNotifications < ActiveRecord::Migration # :nodoc:
  
  def self.up
    create_table :apn_broadcast_notifications do |t|
      t.integer :errors_nb, :default => 0 # used for storing errors from apple feedbacks
      t.string :device_language, :size => 5 # if you don't want to send localized strings
      t.string :sound
      t.string :alert, :size => 150
      t.string :badge
      t.datetime :sent_at
      t.string :state
      t.timestamps
    end
  end

  def self.down
    drop_table :apn_broadcast_notifications
  end
  
end