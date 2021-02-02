RSpec.describe 'Messages Endpoints', type: :request do
  include_context 'API Context'

  describe 'GET app/:app_token/chats/:chat_number/messages' do
    let(:chat) { create(:chat) }
    let!(:messages) { create_list(:message, 3, chat_id: chat.id) }
    let(:messages_json) { JSON.parse ActiveModel::Serializer::CollectionSerializer.new(messages, serializer: MessageSerializer).to_json }

    context 'when valid' do
      it 'returns messages for specific app and chat' do
        get app_chat_messages_path(chat.app.token, chat.number)
        expect(response).to be_ok
        expect(payload).to match_array(messages_json)
      end
    end

    context 'when invalid' do
      it 'returns not_found if app_token is wrong' do
        get app_chat_messages_path('wrong_token', chat.number)
        expect(response).to be_not_found
      end

      it 'returns not_found if chat_number is wrong' do
        get app_chat_messages_path(chat.app.token, '0')
        expect(response).to be_not_found
      end
    end
  end

  describe 'GET app/:app_token/chats/:chat_number/messages/search' do
    let(:chat1) { create(:chat) }
    let!(:message1) { create(:message, chat_id: chat1.id, body: 'hello', number: 2) }
    let(:chat2) { create(:chat) }
    let!(:message2) { create(:message, chat_id: chat2.id, body: 'world', number: 3) }

    before do
      Message.search_index.refresh
    end

    context 'when valid' do
      it 'returns correct message scoped to specific chat for partially matched query', search: true do
        get search_app_chat_messages_path(chat1.app.token, chat1.number, q: 'hell')
        expect(response).to be_ok
        expect(payload.size).to eq 1
        expect(payload.first['number']).to eq message1.number
      end

      it 'returns correct message scoped to specific chat for full matched query', search: true do
        get search_app_chat_messages_path(chat2.app.token, chat2.number, q: 'world')
        expect(response).to be_ok
        expect(payload.size).to eq 1
        expect(payload.first['number']).to eq message2.number
      end

      it 'returns empty array if query matched a message for another chat', search: true do
        get search_app_chat_messages_path(chat1.app.token, chat1.number, q: 'world')
        expect(response).to be_ok
        expect(payload).to be_blank
      end

      it "returns empty array if query didn't match any messages", search: true do
        get search_app_chat_messages_path(chat1.app.token, chat1.number, q: 'wrong query')
        expect(response).to be_ok
        expect(payload).to be_blank
      end
    end

    context 'when invalid' do
      it 'returns not_found if app_token is wrong', search: true do
        get search_app_chat_messages_path('wrong_token', chat1.number, q: 'hell')
        expect(response).to be_not_found
      end

      it 'returns not_found if chat_number is wrong', search: true do
        get search_app_chat_messages_path(chat1.app.token, '0', q: 'hell')
        expect(response).to be_not_found
      end
    end
  end

  describe 'GET app/:app_token/chats/:chat_number/messages/:number' do
    let(:some_message) { create(:message) }

    context 'when valid' do
      it 'returns a chat message' do
        get app_chat_message_path(some_message.chat.app.token, some_message.chat.number, some_message.number)
        expect(response).to be_ok
        expect(payload['number']).to eq some_message.number
        expect(payload['body']).to eq some_message.body
      end
    end

    context 'when invalid' do
      it 'returns not_found if app_token is wrong' do
        get app_chat_message_path('wrong_token', some_message.chat.number, some_message.number)
        expect(response).to be_not_found
      end

      it 'returns not_found if chat_number is wrong' do
        get app_chat_message_path(some_message.chat.app.token, '0', some_message.number)
        expect(response).to be_not_found
      end

      it 'returns not_found if message_number is wrong' do
        get app_chat_message_path(some_message.chat.app.token, some_message.chat.number, '0')
        expect(response).to be_not_found
      end
    end
  end
end
