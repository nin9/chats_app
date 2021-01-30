class CreateMessage
  include Sidekiq::Worker
  sidekiq_options queue: 'messages', retry: false

  def perform(app_token, chat_number, message_number, body)
    app = App.find_by!(token: app_token)
    chat = app.chats.find_by!(number: chat_number)
    chat.with_lock do
      Message.create!(chat: chat, number: message_number, body: body)
      chat.update!(messages_count: chat.messages_count + 1)
    end
  end
end
