require 'rails_helper'

RSpec.describe "Campaign to Exchange Flow E2E", type: :system do
  let(:user) { create(:user) }
  let!(:target) { create(:target, name: "US Desktop Traffic") }

  before do
    # Mock authorization
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    
    # Mock bidder/exchange HTTP calls with WebMock
    stub_const("RTB_CROSSTALK_REGION_HOSTS", {
      "us-east" => "bidder-us-east.example.com",
      "us-west" => "bidder-us-west.example.com"
    })
    stub_const("RTB_CROSSTALK_PORT", "8888")
    stub_const("RTB_CROSSTALK_USER", "test_user")
    stub_const("RTB_CROSSTALK_PASSWORD", "test_password")

    # Stub bidder ping
    stub_request(:post, "http://bidder-us-east.example.com:8888/api")
      .with(body: hash_including("type" => "Ping#"))
      .to_return(status: 200, body: "OK")
    
    stub_request(:post, "http://bidder-us-west.example.com:8888/api")
      .with(body: hash_including("type" => "Ping#"))
      .to_return(status: 200, body: "OK")
  end

  describe "Complete campaign creation and exchange sync flow" do
    it "creates campaign, adds banners, and syncs to exchange" do
      # Step 1: Create Campaign
      visit new_campaign_path

      fill_in "Name", with: "E2E Test Campaign"
      fill_in "Ad Domain", with: "advertiser.example.com"
      fill_in "Total Budget", with: "50000.00"
      fill_in "Daily Budget", with: "2000.00"
      fill_in "Hourly Budget", with: "100.00"
      
      select target.name, from: "Target"
      check "Google"  # Select exchange
      check "Rubicon"
      
      # Set time windows
      fill_in "Activate Time", with: (Time.now).strftime("%Y-%m-%dT%H:%M")
      fill_in "Expire Time", with: (Time.now + 30.days).strftime("%Y-%m-%dT%H:%M")

      # Stub campaign update to bidder
      stub_request(:post, /bidder.*:8888\/api/)
        .with(body: hash_including("type" => "Update#"))
        .to_return(status: 200, body: '{"status":"ok"}')

      click_button "Create Campaign"

      expect(page).to have_content("Campaign was successfully created")
      
      campaign = Campaign.last
      expect(campaign.name).to eq("E2E Test Campaign")
      expect(campaign.total_budget).to eq(50000.00)
      
      # Verify bidder update was called
      expect(WebMock).to have_requested(:post, /bidder.*:8888\/api/)
        .with(body: hash_including("type" => "Update#", "campaign" => campaign.id.to_s))

      # Step 2: Add Banner to Campaign
      visit new_banner_path

      fill_in "Name", with: "Campaign Banner 1"
      fill_in "Bid ECPM", with: "5.00"
      fill_in "Image URL", with: "https://cdn.example.com/banner1.jpg"
      select "image/jpeg", from: "Content Type"
      select campaign.name, from: "Campaign"
      
      fill_in "Hourly Budget", with: "25.00"
      fill_in "Daily Budget", with: "500.00"
      fill_in "Total Budget", with: "10000.00"

      find("#banner_interval_start", visible: false).set(Time.now.strftime("%m-%d-%Y %H%M"))
      find("#banner_interval_end", visible: false).set((Time.now + 30.days).strftime("%m-%d-%Y %H%M"))

      click_button "Create Banner"

      expect(page).to have_content("Banner was successfully created")
      
      banner = Banner.last
      expect(banner.campaign).to eq(campaign)
      
      # Verify bidder sync after banner creation
      expect(WebMock).to have_requested(:post, /bidder.*:8888\/api/)
        .with(body: hash_including("campaign" => campaign.id.to_s))
        .at_least_once

      # Step 3: View Campaign Dashboard
      visit campaign_path(campaign)

      expect(page).to have_content("E2E Test Campaign")
      expect(page).to have_content("Campaign Banner 1")
      expect(page).to have_content("$5.00")  # ECPM

      # Step 4: Update Campaign (should trigger bidder sync)
      visit edit_campaign_path(campaign)

      fill_in "Total Budget", with: "75000.00"
      
      click_button "Update Campaign"

      expect(page).to have_content("Campaign was successfully updated")
      
      # Verify bidder update was called again
      expect(WebMock).to have_requested(:post, /bidder.*:8888\/api/)
        .with(body: hash_including("type" => "Update#", "campaign" => campaign.id.to_s))
        .at_least_twice

      # Step 5: Check campaign status and errors
      visit campaigns_path

      expect(page).to have_content("E2E Test Campaign")
      
      # Campaign should be runnable if all validations pass
      campaign.reload
      errors = campaign.check_errors
      expect(errors).to be_empty
    end

    it "handles bidder unavailability gracefully" do
      # Stub bidder as unavailable
      stub_request(:post, /bidder.*:8888\/api/)
        .to_timeout

      visit new_campaign_path

      fill_in "Name", with: "Campaign with Offline Bidder"
      fill_in "Ad Domain", with: "test.example.com"
      fill_in "Total Budget", with: "10000.00"
      select target.name, from: "Target"
      check "Google"
      
      fill_in "Activate Time", with: (Time.now).strftime("%Y-%m-%dT%H:%M")
      fill_in "Expire Time", with: (Time.now + 30.days).strftime("%Y-%m-%dT%H:%M")

      click_button "Create Campaign"

      # Campaign should still be created even if bidder sync fails
      expect(page).to have_content("error") # Error message about bidder sync
      expect(Campaign.last.name).to eq("Campaign with Offline Bidder")
    end
  end

  describe "Campaign deletion and exchange cleanup" do
    let!(:campaign) { create(:campaign, :with_banners, name: "Campaign to Delete") }

    it "removes campaign from exchange when deleted" do
      # Stub delete command
      stub_request(:post, /bidder.*:8888\/api/)
        .with(body: hash_including("type" => "Delete#", "campaign" => campaign.id.to_s))
        .to_return(status: 200, body: '{"status":"ok"}')

      visit campaigns_path

      expect(page).to have_content("Campaign to Delete")

      accept_confirm do
        click_link "Destroy", match: :first
      end

      expect(page).to have_content("Campaign was successfully destroyed")
      
      # Verify delete was sent to bidder
      expect(WebMock).to have_requested(:post, /bidder.*:8888\/api/)
        .with(body: hash_including("type" => "Delete#", "campaign" => campaign.id.to_s))
    end
  end

  describe "Campaign budget enforcement" do
    let!(:campaign) { 
      create(:campaign, 
        name: "Over Budget Campaign",
        total_budget: 1000.00,
        cost: 1500.00,  # Over budget
        status: "runnable"
      )
    }

    it "displays budget errors on dashboard" do
      visit campaigns_path

      expect(page).to have_content("Over Budget Campaign")
      expect(page).to have_css(".text-danger")  # Error styling
      
      # Campaign should show error about being over budget
      errors = campaign.check_errors
      expect(errors).to include(match(/cost.*greater than budget/i))
    end

    it "prevents campaign from being loaded to exchange when over budget" do
      visit campaign_path(campaign)

      # Error should be visible
      expect(page).to have_content(match(/cost.*greater than budget/i))
    end
  end
end
