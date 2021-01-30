shared_context 'API Context' do
  let(:payload) { JSON.parse(response.body) }
end
