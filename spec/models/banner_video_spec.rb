require 'rails_helper'

RSpec.describe BannerVideo, type: :model do
  describe 'associations' do
    it { should belong_to(:campaign) }
    it { should belong_to(:target) }
    it { should have_and_belong_to_many(:rtb_standards) }
    it { should have_many(:report_commands) }
    it { should have_many(:exchange_attributes).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:interval_start) }
    it { should validate_presence_of(:interval_end) }
    it { should validate_presence_of(:mime_type) }
    it { should validate_presence_of(:bid_ecpm) }
    it { should validate_presence_of(:bitrate) }
    it { should validate_numericality_of(:bid_ecpm) }
    it { should validate_numericality_of(:bitrate).is_greater_than(0) }
  end

  describe '#check_errors' do
    let(:video) { create(:banner_video) }

    it 'returns hourly budget error when hourly cost exceeds budget' do
      video.update_columns(hourly_budget: 10.00, hourly_cost: 15.00)
      errors = video.check_errors
      expect(errors).to include(match(/hourly cost.*greater than budget/i))
    end

    it 'returns empty array when valid' do
      errors = video.check_errors
      expect(errors).to be_empty
    end
  end

  describe 'factory' do
    it 'creates a valid banner video' do
      video = build(:banner_video)
      expect(video).to be_valid
    end

    it 'creates a video with dimensions' do
      video = build(:banner_video, :with_dimensions)
      expect(video.width_range).to match(/\d+-\d+/)
    end
  end
end
