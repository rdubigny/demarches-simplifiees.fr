class SendClosingNotificationJob < ApplicationJob
  def perform(users, content, procedure)
    users.each do |user|
      Expired::MailRateLimiter.new().send_with_delay(UserMailer.notify_after_closing(user, content, @procedure))
    end
  end
end
