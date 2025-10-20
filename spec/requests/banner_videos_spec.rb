require 'rails_helper'

RSpec.describe "BannerVideos", type: :request do
  before do
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_return(true)
    allow(Bidder).to receive(:ping).and_return(true)
  end

  let(:campaign) { create(:campaign) }
  let(:target) { create(:target) }
  let(:valid_attributes) do
    {
      name: "Test Video",
      interval_start: Time.now,
      interval_end: Time.now + 30.days,
      mime_type: "video/mp4",
      bid_ecpm: 5.00,
      bitrate: 1500,
      campaign_id: campaign.id,
      target_id: target.id
    }
  end

  describe "GET /banner_videos" do
    it "returns success" do
      get banner_videos_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /banner_videos" do
    it "creates a new BannerVideo" do
      expect {
        post banner_videos_path, params: { banner_video: valid_attributes }
      }.to change(BannerVideo, :count).by(1)
    end
  end

  describe "DELETE /banner_videos/:id" do
    it "destroys the requested banner_video" do
      video = create(:banner_video)
      expect {
        delete banner_video_path(video)
      }.to change(BannerVideo, :count).by(-1)
    end
  end
end
