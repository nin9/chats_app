RSpec.describe 'Apps Endpoints', type: :request do
  include_context 'API Context'

  describe 'GET /apps' do
    let!(:apps) { create_list(:app, 3) }
    let(:apps_json) { JSON.parse ActiveModel::Serializer::CollectionSerializer.new(apps, serializer: AppSerializer).to_json }

    context 'when valid' do
      it 'returns apps' do
        get apps_path
        expect(response).to be_ok
        expect(payload).to match_array(apps_json)
      end
    end
  end

  describe 'POST /apps' do
    context 'when valid' do
      it 'creates an app' do
        post apps_path, params: { name: 'app' }
        expect(response).to be_created
        expect(payload['name']).to eq 'app'
      end
    end

    context 'when invalid' do
      it 'returns an error if name is missing' do
        post apps_path, params: {}
        expect(response).to be_unprocessable
      end
    end
  end

  describe 'GET /apps/:token' do
    let(:some_app) { create(:app) }

    context 'when valid' do
      it 'gets app of the specified token' do
        get app_path(some_app.token)
        expect(response).to be_ok
        expect(payload['token']).to eq some_app.token
        expect(payload['name']).to eq some_app.name
      end
    end

    context 'when invalid' do
      it 'returns not found if token is wrong' do
        get app_path('wrong_token')
        expect(response).to be_not_found
      end
    end
  end
end
