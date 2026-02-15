# frozen_string_literal: true

module RequestSpecHelper
  def setup_authentication
    # Disable the create_personal_organization callback during factory creation
    allow_any_instance_of(User).to receive(:create_personal_organization)

    # Create real user and organization (or use existing from let! blocks)
    # Use a unique email to avoid conflicts if test already created a user
    @test_user = @user || user rescue nil  # Try to use existing user from let! block

    unless @test_user
      @test_user = create(:user, name: 'Test User', email: "test-#{SecureRandom.hex(4)}@example.com")
    end

    # Create organization if not already set
    @test_organization = @organization || organization rescue nil
    unless @test_organization
      @test_organization = create(:organization, name: 'Test Org', owner: @test_user)
    end

    @test_user.update(current_organization: @test_organization)

    # Stub current_user to return our test user (bypasses session auth)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@test_user)

    # Stub bidder calls to prevent external HTTP requests
    # Note: Individual tests can override these with more specific expectations
    allow(Bidder).to receive(:ping).and_return(true)
    allow(Bidder).to receive(:updateCampaign).and_return(true)
    allow(Bidder).to receive(:deleteCampaign).and_return(true)

    # Don't stub update_bidder/remove_bidder globally - let tests that need it stub explicitly
    # This allows tests to verify these methods are called when needed
  end
end

RSpec.configure do |config|
  config.include RequestSpecHelper, type: :request
end
