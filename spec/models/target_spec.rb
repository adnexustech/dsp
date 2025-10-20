require 'rails_helper'

RSpec.describe Target, type: :model do
  describe 'associations' do
    it { should have_many(:campaigns) }
    it { should have_many(:banners) }
    it { should have_many(:banner_videos) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:activate_time) }
    it { should validate_presence_of(:expire_time) }

    describe 'expire_time_cannot_be_in_the_past' do
      let(:target) { build(:target) }

      it 'is invalid when expire_time is in the past' do
        target.expire_time = Time.now - 1.day
        expect(target).not_to be_valid
        expect(target.errors[:expire_time]).to include("can't be in the past")
      end

      it 'is invalid when activate_time is after expire_time' do
        target.activate_time = Time.now + 2.days
        target.expire_time = Time.now + 1.day
        expect(target).not_to be_valid
        expect(target.errors[:expire_time]).to include("can't be before activate time")
      end
    end
  end

  describe '#check_time' do
    let(:target) { create(:target) }

    it 'returns true when time is valid' do
      expect(target.check_time).to be true
    end

    it 'returns false when not yet active' do
      target.update_column(:activate_time, Time.now + 1.hour)
      expect(target.check_time).to be false
    end

    it 'returns false when expired' do
      target.update_column(:expire_time, Time.now - 1.hour)
      expect(target.check_time).to be false
    end
  end

  describe '#check_errors' do
    let(:target) { create(:target) }

    it 'returns errors when expired' do
      target.update_column(:expire_time, Time.now - 1.day)
      errors = target.check_errors
      expect(errors).to include(match(/expire time in the past/i))
    end

    it 'returns errors when not yet active' do
      target.update_column(:activate_time, Time.now + 1.day)
      errors = target.check_errors
      expect(errors).to include(match(/activate time in the future/i))
    end

    it 'returns empty array when valid' do
      errors = target.check_errors
      expect(errors).to be_empty
    end
  end

  describe 'callbacks' do
    it 'has set_campaign_updated_at callback' do
      target = create(:target)
      expect(target).to respond_to(:set_campaign_updated_at)
    end
  end

  describe 'factory' do
    it 'creates a valid target' do
      target = build(:target)
      expect(target).to be_valid
    end
  end
end
