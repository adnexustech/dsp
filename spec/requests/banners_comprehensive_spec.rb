require 'rails_helper'

RSpec.describe "Banners Comprehensive CRUD", type: :request do
  before do
    setup_authentication
    allow(Bidder).to receive(:ping).and_return(true)
    allow(Bidder).to receive(:updateCampaign).and_return(true)
  end

  let(:campaign) { create(:campaign) }
  let(:target) { create(:target) }
  let(:rtb_standard) { create(:rtb_standard) }

  describe "POST /banners - Full Create Flow" do
    context "with minimal valid parameters (no campaign/target)" do
      let(:minimal_params) do
        {
          banner: {
            name: "Minimal Banner",
            interval_start: Time.now,
            interval_end: Time.now + 30.days,
            iurl: "https://example.com/banner.jpg",
            contenttype: "image/jpeg",
            bid_ecpm: 5.00
          }
        }
      end

      it "creates banner successfully" do
        expect {
          post banners_path, params: minimal_params
        }.to change(Banner, :count).by(1)

        expect(response).to have_http_status(:redirect)
        banner = Banner.last
        expect(banner.name).to eq("Minimal Banner")
        expect(banner.bid_ecpm).to eq(5.00)
        expect(banner.campaign).to be_nil
        expect(banner.target).to be_nil
      end
    end

    context "with full parameters including associations" do
      let(:full_params) do
        {
          banner: {
            name: "Full Banner",
            interval_start: Time.now,
            interval_end: Time.now + 30.days,
            iurl: "https://example.com/banner.jpg",
            contenttype: "text/html",
            bid_ecpm: 7.50,
            campaign_id: campaign.id,
            target_id: target.id,
            rtb_standard_ids: [rtb_standard.id],
            hourly_budget: 25.00,
            daily_budget: 500.00,
            total_basket_value: 10000.00,
            frequency_spec: "device.ip",
            frequency_count: 3,
            frequency_expire: 3600
          }
        }
      end

      it "creates banner with all associations" do
        expect {
          post banners_path, params: full_params
        }.to change(Banner, :count).by(1)

        banner = Banner.last
        expect(banner.name).to eq("Full Banner")
        expect(banner.campaign).to eq(campaign)
        expect(banner.target).to eq(target)
        expect(banner.rtb_standards).to include(rtb_standard)
        expect(banner.hourly_budget).to eq(25.00)
        expect(banner.daily_budget).to eq(500.00)
      end

      it "syncs with bidder when campaign present" do
        expect_any_instance_of(Campaign).to receive(:update_bidder).and_return(true)

        post banners_path, params: full_params
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          banner: {
            name: "",  # Missing required field
            bid_ecpm: -5.00  # Invalid negative price
          }
        }
      end

      it "does not create banner" do
        expect {
          post banners_path, params: invalid_params
        }.to change(Banner, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns proper Turbo response" do
        post banners_path, params: invalid_params
        expect(response.status).to eq(422)
      end
    end

    context "with date parameters" do
      it "parses interval_start correctly" do
        post banners_path, params: {
          banner: {
            name: "Date Test Banner",
            iurl: "https://example.com/test.jpg",
            contenttype: "image/jpeg",
            bid_ecpm: 2.50
          },
          interval_start: "10-25-2025 1400",
          interval_end: "11-25-2025 1500"
        }

        banner = Banner.last
        expect(banner.interval_start).to be_present
        expect(banner.interval_end).to be_present
      end
    end
  end

  describe "PATCH /banners/:id - Full Update Flow" do
    let!(:banner) { create(:banner, :with_campaign, :with_target) }

    context "updating basic attributes" do
      it "updates successfully" do
        patch banner_path(banner), params: {
          banner: { name: "Updated Banner Name", bid_ecpm: 10.00 }
        }

        banner.reload
        expect(banner.name).to eq("Updated Banner Name")
        expect(banner.bid_ecpm).to eq(10.00)
        expect(response).to have_http_status(:redirect)
      end
    end

    context "removing campaign association" do
      it "removes campaign and syncs bidder" do
        expect_any_instance_of(Campaign).to receive(:update_bidder).and_return(true)

        patch banner_path(banner), params: {
          banner: { campaign_id: nil }
        }

        banner.reload
        expect(banner.campaign).to be_nil
      end
    end

    context "with validation errors" do
      it "returns unprocessable_entity status" do
        patch banner_path(banner), params: {
          banner: { name: "", bid_ecpm: -1 }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        banner.reload
        expect(banner.name).not_to be_empty  # Should not update
      end
    end
  end

  describe "DELETE /banners/:id - Full Delete Flow" do
    let!(:banner) { create(:banner, :with_campaign) }

    context "when bidder is reachable" do
      before do
        allow(Bidder).to receive(:ping).and_return(true)
      end

      it "destroys banner and syncs bidder" do
        expect_any_instance_of(Campaign).to receive(:update_bidder).and_return(true)

        expect {
          delete banner_path(banner)
        }.to change(Banner, :count).by(-1)

        expect(response).to redirect_to(banners_url)
      end
    end

    context "when bidder is unreachable" do
      before do
        allow(Bidder).to receive(:ping).and_return(false)
      end

      it "does not destroy banner and shows error" do
        expect {
          delete banner_path(banner)
        }.to change(Banner, :count).by(0)

        expect(response).to have_http_status(:redirect)
        expect(flash[:notice]).to include("Unable to connect to bidder")
      end
    end
  end

  describe "GET /banners - Index with filtering" do
    let!(:banner1) { create(:banner, :with_campaign, name: "Alpha Banner") }
    let!(:banner2) { create(:banner, name: "Beta Banner") }
    let!(:banner3) { create(:banner, :with_campaign, name: "Gamma Banner") }

    it "displays all banners" do
      get banners_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Alpha Banner")
      expect(response.body).to include("Beta Banner")
      expect(response.body).to include("Gamma Banner")
    end

    it "shows campaign associations" do
      get banners_path
      expect(response.body).to include(banner1.campaign.name)
      expect(response.body).to include(banner3.campaign.name)
    end
  end

  describe "GET /banners/:id - Show page" do
    let!(:banner) { create(:banner, :with_campaign, :with_target) }

    it "displays banner details" do
      get banner_path(banner)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(banner.name)
      expect(response.body).to include(banner.bid_ecpm.to_s)
    end

    it "displays formatted budget information" do
      banner.update(hourly_budget: 25.00, daily_budget: 500.00, total_basket_value: 10000.00)
      get banner_path(banner)
      
      expect(response.body).to include("25.00")
      expect(response.body).to include("500.00")
      expect(response.body).to include("10000.00")
    end
  end
end
