require 'rails_helper'

RSpec.describe "Banners", type: :request do
  before do
    setup_authentication
  end

  let(:campaign) { create(:campaign) }
  let(:target) { create(:target) }
  let(:valid_attributes) do
    {
      name: "Test Banner",
      interval_start: Time.now,
      interval_end: Time.now + 30.days,
      iurl: "http://example.com/image.jpg",
      htmltemplate: "<div>Ad</div>",
      contenttype: "text/html",
      bid_ecpm: 2.50,
      campaign_id: campaign.id,
      target_id: target.id
    }
  end

  let(:invalid_attributes) { { name: nil, contenttype: nil, bid_ecpm: nil } }

  describe "GET /banners" do
    it "returns success" do
      get banners_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /banners/:id" do
    it "returns success" do
      banner = create(:banner)
      get banner_path(banner)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /banners/new" do
    it "returns success" do
      get new_banner_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /banners/:id/edit" do
    it "returns success" do
      banner = create(:banner)
      get edit_banner_path(banner)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /banners" do
    context "with valid parameters" do
      it "creates a new Banner" do
        expect {
          post banners_path, params: { banner: valid_attributes }
        }.to change(Banner, :count).by(1)
      end

      it "redirects to the created banner" do
        post banners_path, params: { banner: valid_attributes }
        expect(response).to redirect_to(Banner.last)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Banner" do
        expect {
          post banners_path, params: { banner: invalid_attributes }
        }.to change(Banner, :count).by(0)
      end
    end
  end

  describe "PATCH /banners/:id" do
    let(:banner) { create(:banner) }
    let(:new_attributes) { { name: "Updated Banner" } }

    context "with valid parameters" do
      it "updates the requested banner" do
        patch banner_path(banner), params: { banner: new_attributes }
        banner.reload
        expect(banner.name).to eq("Updated Banner")
      end

      it "redirects to the banner" do
        patch banner_path(banner), params: { banner: new_attributes }
        expect(response).to redirect_to(banner)
      end
    end
  end

  describe "DELETE /banners/:id" do
    it "destroys the requested banner" do
      banner = create(:banner)
      expect {
        delete banner_path(banner)
      }.to change(Banner, :count).by(-1)
    end

    it "redirects to the banners list" do
      banner = create(:banner)
      delete banner_path(banner)
      expect(response).to redirect_to(banners_url)
    end
  end
end
