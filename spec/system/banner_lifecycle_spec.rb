require 'rails_helper'

RSpec.describe "Banner Lifecycle E2E", type: :system do
  let(:user) { create(:user) }
  let!(:campaign) { create(:campaign, name: "Test Campaign") }
  let!(:target) { create(:target, name: "Test Target") }

  before do
    # Mock authorization
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    
    # Mock bidder responses
    stub_request(:post, /bidder.*:8888\/api/)
      .to_return(status: 200, body: '{"status":"ok"}')
  end

  describe "Creating a new banner" do
    it "allows user to create banner without campaign/target" do
      visit new_banner_path

      fill_in "Name", with: "E2E Test Banner"
      fill_in "Bid ECPM", with: "5.00"
      fill_in "Image URL", with: "https://example.com/banner.jpg"
      select "image/jpeg", from: "Content Type"
      
      # Set dates (these are handled by JavaScript date pickers in real UI)
      # For testing, we'll fill the actual datetime fields
      find("#banner_interval_start", visible: false).set(Time.now.strftime("%m-%d-%Y %H%M"))
      find("#banner_interval_end", visible: false).set((Time.now + 30.days).strftime("%m-%d-%Y %H%M"))

      click_button "Create Banner"

      expect(page).to have_content("Banner was successfully created")
      expect(Banner.last.name).to eq("E2E Test Banner")
      expect(Banner.last.bid_ecpm).to eq(5.00)
    end

    it "allows user to create banner with full details" do
      visit new_banner_path

      fill_in "Name", with: "Full E2E Banner"
      fill_in "Bid ECPM", with: "7.50"
      fill_in "Image URL", with: "https://example.com/full-banner.jpg"
      select "text/html", from: "Content Type"
      
      # Associate with campaign and target
      select campaign.name, from: "Campaign"
      select target.name, from: "Target"

      # Budget fields
      fill_in "Hourly Budget", with: "25.00"
      fill_in "Daily Budget", with: "500.00"
      fill_in "Total Budget", with: "10000.00"

      # Frequency capping
      fill_in "Frequency Spec", with: "device.ip"
      fill_in "Frequency Count", with: "3"
      fill_in "Frequency Expire", with: "3600"

      # Dates
      find("#banner_interval_start", visible: false).set(Time.now.strftime("%m-%d-%Y %H%M"))
      find("#banner_interval_end", visible: false).set((Time.now + 30.days).strftime("%m-%d-%Y %H%M"))

      click_button "Create Banner"

      expect(page).to have_content("Banner was successfully created")
      
      banner = Banner.last
      expect(banner.name).to eq("Full E2E Banner")
      expect(banner.campaign).to eq(campaign)
      expect(banner.target).to eq(target)
      expect(banner.hourly_budget).to eq(25.00)
      expect(banner.daily_budget).to eq(500.00)
    end

    it "shows validation errors for invalid input" do
      visit new_banner_path

      # Submit without required fields
      click_button "Create Banner"

      expect(page).to have_content("error") # Validation error message
      expect(Banner.count).to eq(0)
    end
  end

  describe "Editing an existing banner" do
    let!(:banner) { create(:banner, :with_campaign, name: "Original Banner") }

    it "allows user to update banner details" do
      visit edit_banner_path(banner)

      fill_in "Name", with: "Updated Banner Name"
      fill_in "Bid ECPM", with: "15.00"

      click_button "Update Banner"

      expect(page).to have_content("Banner was successfully updated")
      
      banner.reload
      expect(banner.name).to eq("Updated Banner Name")
      expect(banner.bid_ecpm).to eq(15.00)
    end

    it "allows removing campaign association" do
      visit edit_banner_path(banner)

      select "", from: "Campaign"  # Clear campaign selection

      click_button "Update Banner"

      expect(page).to have_content("Banner was successfully updated")
      
      banner.reload
      expect(banner.campaign).to be_nil
    end
  end

  describe "Viewing banners" do
    let!(:banner1) { create(:banner, :with_campaign, name: "Banner Alpha") }
    let!(:banner2) { create(:banner, name: "Banner Beta") }

    it "displays all banners in index" do
      visit banners_path

      expect(page).to have_content("Banner Alpha")
      expect(page).to have_content("Banner Beta")
      expect(page).to have_content(banner1.campaign.name)
    end

    it "displays banner details on show page" do
      visit banner_path(banner1)

      expect(page).to have_content(banner1.name)
      expect(page).to have_content("$#{sprintf('%.2f', banner1.bid_ecpm)}")
      expect(page).to have_content(banner1.iurl)
    end
  end

  describe "Deleting a banner" do
    let!(:banner) { create(:banner, :with_campaign, name: "Banner to Delete") }

    it "allows user to delete banner" do
      visit banners_path

      expect(page).to have_content("Banner to Delete")

      accept_confirm do
        click_link "Destroy", match: :first
      end

      expect(page).to have_content("Banner was successfully destroyed")
      expect(page).not_to have_content("Banner to Delete")
      expect(Banner.find_by(name: "Banner to Delete")).to be_nil
    end
  end

  describe "Banner error checking" do
    let!(:banner) { 
      create(:banner, 
        :with_campaign,
        total_basket_value: 100.00,
        total_cost: 150.00  # Over budget
      )
    }

    it "displays budget errors on index page" do
      visit banners_path

      expect(page).to have_content(banner.name)
      # Budget error should be displayed
      expect(page).to have_css(".text-danger")
    end
  end
end
