class CreateChat
  include Sidekiq::Worker
  sidekiq_options queue: 'chats', retry: false

  def perform(app_token, chat_number)
    app = App.find_by!(token: app_token)
    app.with_lock do
      Chat.create!(app: app, number: chat_number)
      app.update!(chats_count: app.chats_count + 1)
    end
  end
end
