class ApplicationController < ActionController::API
  include ExceptionHandler
  include ::ActionController::Serialization
end
