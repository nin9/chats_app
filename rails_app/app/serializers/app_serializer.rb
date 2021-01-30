class AppSerializer < ActiveModel::Serializer
  attributes :name, :token, :chats_count
end
