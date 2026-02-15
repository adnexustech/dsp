require 'rails_helper'

RSpec.describe Campaign, type: :model do
  describe 'associations' do
    it { should have_many(:banners).dependent(:destroy) }
    it { should have_many(:banner_videos).dependent(:destroy) }
    it { should belong_to(:target).optional }
    it { should have_and_belong_to_many(:rtb_standards) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:activate_time) }
    it { should validate_presence_of(:expire_time) }
    it { should validate_presence_of(:ad_domain) }
    it { should validate_presence_of(:regions) }
    it { should validate_presence_of(:total_budget) }
    it { should validate_numericality_of(:total_budget).is_greater_than(0) }

    describe 'expire_time_cannot_be_in_the_past' do
      let(:campaign) { build(:campaign) }

      context 'when expire_time is in the past' do
        it 'is invalid' do
          campaign.expire_time = Time.now - 1.day
          expect(campaign).not_to be_valid
          expect(campaign.errors[:expire_time]).to include("can't be in the past")
        end
      end

      context 'when expire_time is before activate_time' do
        it 'is invalid' do
          campaign.activate_time = Time.now + 2.days
          campaign.expire_time = Time.now + 1.day
          expect(campaign).not_to be_valid
          expect(campaign.errors[:expire_time]).to include("can't be before activate time")
        end
      end

      context 'when expire_time is valid' do
        it 'is valid' do
          campaign.activate_time = Time.now
          campaign.expire_time = Time.now + 30.days
          expect(campaign).to be_valid
        end
      end
    end
  end

  describe '#check_errors' do
    let(:campaign) { create(:campaign, :with_banners) }

    context 'when campaign status is not runnable' do
      it 'returns empty errors array' do
        campaign.status = 'paused'
        errors = campaign.check_errors
        expect(errors).to be_empty
      end
    end

    context 'when campaign status is runnable' do
      before { campaign.status = 'runnable' }

      context 'when total cost exceeds budget' do
        it 'returns budget error' do
          campaign.update_columns(total_budget: 100.00, cost: 150.00)
          errors = campaign.check_errors
          expect(errors).to include(match(/total cost.*greater than budget/i))
        end
      end

      context 'when daily cost exceeds daily budget' do
        it 'returns daily budget error' do
          campaign.update_columns(budget_limit_daily: 50.00, daily_cost: 75.00)
          errors = campaign.check_errors
          expect(errors).to include(match(/daily cost.*greater than budget/i))
        end
      end

      context 'when hourly cost exceeds hourly budget' do
        it 'returns hourly budget error' do
          campaign.update_columns(budget_limit_hourly: 10.00, hourly_cost: 15.00)
          errors = campaign.check_errors
          expect(errors).to include(match(/hourly cost.*greater than budget/i))
        end
      end

      context 'when campaign is expired' do
        it 'returns expired error' do
          campaign.update_column(:expire_time, Time.now - 1.day)
          errors = campaign.check_errors
          expect(errors).to include(match(/time expired/i))
        end
      end

      context 'when campaign is not yet active' do
        it 'returns not active error' do
          campaign.update_column(:activate_time, Time.now + 1.day)
          errors = campaign.check_errors
          expect(errors).to include(match(/not yet active/i))
        end
      end

      context 'when campaign has no creatives' do
        it 'returns no creatives error' do
          campaign.banners.destroy_all
          campaign.banner_videos.destroy_all
          errors = campaign.check_errors
          expect(errors).to include(match(/no banners or videos/i))
        end
      end

      context 'when campaign has no target' do
        it 'returns no target error' do
          campaign.update_column(:target_id, nil)
          errors = campaign.check_errors
          expect(errors).to include(match(/target is not defined/i))
        end
      end

      context 'when all validations pass' do
        it 'returns empty errors array' do
          errors = campaign.check_errors
          expect(errors).to be_empty
        end
      end
    end
  end

  describe '#set_updated_at' do
    let(:campaign) { create(:campaign) }

    it 'sets updated_at to current time' do
      freeze_time = Time.now + 1.day
      allow(Time).to receive(:now).and_return(freeze_time)

      campaign.set_updated_at
      # Use be_within for timestamp comparison to handle microsecond precision
      expect(campaign.updated_at).to be_within(1.second).of(freeze_time)
    end
  end

  describe 'callbacks' do
    let(:campaign) { build(:campaign) }

    it 'calls set_updated_at before update' do
      campaign.save
      expect(campaign).to receive(:set_updated_at)
      campaign.update(name: 'Updated Campaign')
    end

    it 'calls check_exchange_attributes before update' do
      campaign.save
      expect(campaign).to receive(:check_exchange_attributes)
      campaign.update(exchanges: 'google,rubicon')
    end
  end

  describe 'factory' do
    it 'creates a valid campaign' do
      campaign = build(:campaign)
      expect(campaign).to be_valid
    end

    it 'creates an expired campaign with trait' do
      campaign = build(:campaign, :expired)
      expect(campaign.expire_time).to be < Time.now
    end

    it 'creates a not yet active campaign with trait' do
      campaign = build(:campaign, :not_active)
      expect(campaign.activate_time).to be > Time.now
    end

    it 'creates a campaign with banners trait' do
      campaign = create(:campaign, :with_banners)
      expect(campaign.banners.count).to eq(2)
    end
  end
end
