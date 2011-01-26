# desc "Explaining what the task does"
# task :urban_airship_on_rails do
#   # Task goes here
# end

namespace :apn do
  desc "retreive and process list of inactive devices"
  task :feedback => [:environment] do
    APN::Feedback.create().run
  end

  desc "send all pending notifications to devices"
  task :push => [:environment] do
    APN::Notification.process_pending
  end

  desc "send all pending broadcast notifications to devices"
  task :broadcast_push => [:environment] do
    APN::BroadcastNotification.process_pending
  end

end