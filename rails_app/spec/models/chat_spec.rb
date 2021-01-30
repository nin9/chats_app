RSpec.describe Chat, type: :model do
  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to have_many :messages }

  describe 'uniqueness' do
    subject { build(:chat) }

    it { is_expected.to validate_uniqueness_of(:number).scoped_to(:app_id) }
  end
end
