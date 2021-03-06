class MessageNotifier < UserNotifier
  @queue = :foodsoft_notifier

  def self.message_deliver(args)
    message_id = args.first
    message = Message.find(message_id)

    message.message_recipients.each do |message_recipient|
      recipient = message_recipient.user
      if recipient.receive_email?
        Mailer.deliver_now_with_user_locale recipient do
          MessagesMailer.foodsoft_message(recipient, message)
        end
        message_recipient.update_attribute :email_state, :sent
      else
        message_recipient.update_attribute :email_state, :skipped
      end
    end
  end
end
