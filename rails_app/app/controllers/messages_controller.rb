class MessagesController < ApplicationController
  before_action :set_app
  before_action :set_chat

  def index
    render json: @chat.messages, status: :ok
  end

  def show
    message = @chat.messages.find_by!(number: params[:number])
    render json: message, status: :ok
  end

  def search
    messages = Message.search(params[:q], where: { chat_id: @chat.id }, match: :word_start, misspellings: false)
    render json: messages, status: :ok
  end

  private

  def set_app
    @app = App.find_by!(token: params[:app_token])
  end

  def set_chat
    @chat = @app.chats.find_by!(number: params[:chat_number])
  end
end
