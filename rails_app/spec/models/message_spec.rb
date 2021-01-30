RSpec.describe Message, type: :model do
  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to validate_presence_of(:body) }

  describe 'uniqueness' do
    subject { build(:message) }

    it { is_expected.to validate_uniqueness_of(:number).scoped_to(:chat_id) }
  end
end
