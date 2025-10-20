require 'rails_helper'

RSpec.describe "Campaigns", type: :request do
  # Stub authorization
  before do
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_return(true)
    allow(Bidder).to receive(:ping).and_return(true)
    allow(Bidder).to receive(:updateAll).and_return(true)
  end

  let(:target) { create(:target) }
  let(:valid_attributes) do
    {
      name: "Test Campaign",
      activate_time: Time.now,
      expire_time: Time.now + 30.days,
      ad_domain: "example.com",
      regions: "US,CA",
      total_budget: 10000.00,
      target_id: target.id
    }
  end

  let(:invalid_attributes) do
    { name: nil }
  end

  describe "GET /campaigns" do
    it "returns success" do
      get campaigns_path
      expect(response).to have_http_status(:success)
    end

    it "lists campaigns" do
      campaign = create(:campaign)
      get campaigns_path
      expect(response.body).to include(campaign.name)
    end
  end

  describe "GET /campaigns/:id" do
    it "returns success" do
      campaign = create(:campaign)
      get campaign_path(campaign)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /campaigns/new" do
    it "returns success" do
      get new_campaign_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /campaigns/:id/edit" do
    it "returns success" do
      campaign = create(:campaign)
      get edit_campaign_path(campaign)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /campaigns" do
    context "with valid parameters" do
      it "creates a new Campaign" do
        expect {
          post campaigns_path, params: { campaign: valid_attributes }
        }.to change(Campaign, :count).by(1)
      end

      it "redirects to the created campaign" do
        post campaigns_path, params: { campaign: valid_attributes }
        expect(response).to redirect_to(Campaign.last)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Campaign" do
        expect {
          post campaigns_path, params: { campaign: invalid_attributes }
        }.to change(Campaign, :count).by(0)
      end

      it "returns unprocessable entity status" do
        post campaigns_path, params: { campaign: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /campaigns/:id" do
    let(:campaign) { create(:campaign) }
    let(:new_attributes) { { name: "Updated Campaign" } }

    context "with valid parameters" do
      it "updates the requested campaign" do
        patch campaign_path(campaign), params: { campaign: new_attributes }
        campaign.reload
        expect(campaign.name).to eq("Updated Campaign")
      end

      it "redirects to the campaign" do
        patch campaign_path(campaign), params: { campaign: new_attributes }
        expect(response).to redirect_to(campaign)
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity status" do
        patch campaign_path(campaign), params: { campaign: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /campaigns/:id" do
    it "destroys the requested campaign" do
      campaign = create(:campaign)
      expect {
        delete campaign_path(campaign)
      }.to change(Campaign, :count).by(-1)
    end

    it "redirects to the campaigns list" do
      campaign = create(:campaign)
      delete campaign_path(campaign)
      expect(response).to redirect_to(campaigns_url)
    end
  end
end
