RSpec.describe 'Chats Endpoints', type: :request do
  include_context 'API Context'

  describe 'GET /apps/:token/chats' do
    let(:some_app) { create(:app) }
    let!(:chats) { create_list(:chat, 3, app_id: some_app.id) }
    let(:chats_json) { JSON.parse ActiveModel::Serializer::CollectionSerializer.new(chats, serializer: ChatSerializer).to_json }

    context 'when valid' do
      it 'returns chats for specific app' do
        get app_chats_path(some_app.token)
        expect(response).to be_ok
        expect(payload).to match_array(chats_json)
      end
    end

    context 'when invalid' do
      it 'returns not_found if app_token is wrong' do
        get app_chats_path('wrong_token')
        expect(response).to be_not_found
      end
    end
  end

  describe 'GET app/:app_token/chats/:number' do
    let(:some_app) { create(:app) }
    let(:chat) { create(:chat, app_id: some_app.id) }

    context 'when valid' do
      it 'returns chat of app' do
        get app_chat_path(some_app.token, chat.number)
        expect(response).to be_ok
        expect(payload['number']).to eq chat.number
      end
    end

    context 'when invalid' do
      it 'returns not_found if app_token is wrong' do
        get app_chat_path('wrong_token', chat.number)
        expect(response).to be_not_found
      end

      it 'returns not_found if chat number is wrong' do
        get app_chat_path(some_app.token, 'wrong_number')
        expect(response).to be_not_found
      end
    end
  end
end
