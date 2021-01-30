class ChatsController < ApplicationController
  before_action :set_app

  def index
    render json: @app.chats, status: :ok
  end

  def show
    chat = @app.chats.find_by!(number: params[:number])
    render json: chat, status: :ok
  end

  private

  def set_app
    @app = App.find_by!(token: params[:app_token])
  end
end
