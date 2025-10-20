require 'rails_helper'

RSpec.describe Banner, type: :model do
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
    it { should validate_presence_of(:iurl) }
    it { should validate_presence_of(:htmltemplate) }
    it { should validate_presence_of(:contenttype) }
    it { should validate_presence_of(:bid_ecpm) }
    it { should validate_numericality_of(:bid_ecpm) }

    describe 'format validations' do
      let(:banner) { build(:banner) }

      context 'width_range format' do
        it 'accepts valid format' do
          banner.width_range = '300-728'
          expect(banner).to be_valid
        end

        it 'rejects invalid format' do
          banner.width_range = '300x728'
          expect(banner).not_to be_valid
          expect(banner.errors[:width_range]).to include(match(/invalid format/i))
        end
      end

      context 'height_range format' do
        it 'accepts valid format' do
          banner.height_range = '250-600'
          expect(banner).to be_valid
        end

        it 'rejects invalid format' do
          banner.height_range = '250x600'
          expect(banner).not_to be_valid
          expect(banner.errors[:height_range]).to include(match(/invalid format/i))
        end
      end

      context 'width_height_list format' do
        it 'accepts valid format' do
          banner.width_height_list = '300x250,728x90,160x600'
          expect(banner).to be_valid
        end

        it 'rejects invalid format' do
          banner.width_height_list = '300-250,728-90'
          expect(banner).not_to be_valid
          expect(banner.errors[:width_height_list]).to include(match(/invalid format/i))
        end
      end
    end

    describe 'interval_end_cannot_be_in_the_past' do
      let(:banner) { build(:banner) }

      context 'when interval_end is in the past' do
        it 'is invalid' do
          banner.interval_end = Time.now - 1.day
          expect(banner).not_to be_valid
          expect(banner.errors[:interval_end]).to include("can't be in the past")
        end
      end

      context 'when interval_end is before interval_start' do
        it 'is invalid' do
          banner.interval_start = Time.now + 2.days
          banner.interval_end = Time.now + 1.day
          expect(banner).not_to be_valid
          expect(banner.errors[:interval_end]).to include("can't be before interval start")
        end
      end

      context 'when interval_end is valid' do
        it 'is valid' do
          banner.interval_start = Time.now
          banner.interval_end = Time.now + 30.days
          expect(banner).to be_valid
        end
      end
    end
  end

  describe '#check_errors' do
    let(:banner) { create(:banner) }

    context 'when total cost exceeds budget' do
      it 'returns budget error' do
        banner.update_columns(total_basket_value: 100.00, total_cost: 150.00)
        errors = banner.check_errors
        expect(errors).to include(match(/total cost.*greater than budget/i))
      end
    end

    context 'when daily cost exceeds budget' do
      it 'returns daily budget error' do
        banner.update_columns(daily_budget: 50.00, daily_cost: 75.00)
        errors = banner.check_errors
        expect(errors).to include(match(/daily cost.*greater than budget/i))
      end
    end

    context 'when hourly cost exceeds budget' do
      it 'returns hourly budget error' do
        banner.update_columns(hourly_budget: 10.00, hourly_cost: 15.00)
        errors = banner.check_errors
        expect(errors).to include(match(/hourly cost.*greater than budget/i))
      end
    end

    context 'when interval is expired' do
      it 'returns expired error' do
        banner.update_column(:interval_end, Time.now - 1.day)
        errors = banner.check_errors
        expect(errors).to include(match(/interval end time expired/i))
      end
    end

    context 'when interval is not yet active' do
      it 'returns not active error' do
        banner.update_column(:interval_start, Time.now + 1.day)
        errors = banner.check_errors
        expect(errors).to include(match(/not yet active/i))
      end
    end

    context 'when all validations pass' do
      it 'returns empty errors array' do
        errors = banner.check_errors
        expect(errors).to be_empty
      end
    end
  end

  describe '#set_updated_at' do
    let(:banner) { create(:banner) }

    it 'sets updated_at to current time' do
      freeze_time = Time.now + 1.day
      allow(Time).to receive(:now).and_return(freeze_time)

      banner.set_updated_at
      # Use be_within for timestamp comparison to handle microsecond precision
      expect(banner.updated_at).to be_within(1.second).of(freeze_time)
    end
  end

  describe '#set_campaign_updated_at' do
    let(:campaign) { create(:campaign) }
    let(:banner) { create(:banner, campaign: campaign) }

    it 'updates the associated campaign' do
      # Method is called during creation, so we expect at_least once
      expect(campaign).to receive(:set_updated_at).at_least(:once)
      expect(campaign).to receive(:save).at_least(:once)
      banner.set_campaign_updated_at
    end
  end

  describe 'callbacks' do
    let(:banner) { build(:banner) }

    it 'calls set_updated_at before update' do
      banner.save
      expect(banner).to receive(:set_updated_at)
      banner.update(name: 'Updated Banner')
    end

    it 'calls set_campaign_updated_at after update' do
      banner.save
      expect(banner).to receive(:set_campaign_updated_at)
      banner.update(bid_ecpm: 3.50)
    end

    it 'calls set_campaign_updated_at after create' do
      expect_any_instance_of(Banner).to receive(:set_campaign_updated_at)
      create(:banner)
    end
  end

  describe 'factory' do
    it 'creates a valid banner' do
      banner = build(:banner)
      expect(banner).to be_valid
    end

    it 'creates a banner with width range' do
      banner = build(:banner, :with_width_range)
      expect(banner.width_range).to match(/\d+-\d+/)
    end

    it 'creates a banner with height range' do
      banner = build(:banner, :with_height_range)
      expect(banner.height_range).to match(/\d+-\d+/)
    end

    it 'creates a banner with dimensions' do
      banner = build(:banner, :with_dimensions)
      expect(banner.width_height_list).to match(/\d+x\d+(,\d+x\d+)*/)
    end
  end
end
