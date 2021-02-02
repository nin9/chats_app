class AppsController < ApplicationController
  def index
    apps = App.all
    render json: apps, status: :ok
  end

  def create
    app = App.create!(app_params)
    render json: app, status: :created
  end

  def show
    app = App.find_by!(token: params[:token])
    render json: app, status: :ok
  end

  def update
    app = App.find_by!(token: params[:token])
    app.update!(name: app_params[:name])
    render json: app, status: :ok
  end

  private

  def app_params
    params.permit(:name)
  end
end
