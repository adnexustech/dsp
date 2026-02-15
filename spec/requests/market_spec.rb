require 'rails_helper'

RSpec.describe "Markets", type: :request do
  before { setup_authentication }

  describe "GET /market" do
    it "returns http success" do
      get market_index_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /market/:id" do
    it "returns http success" do
      # Create a user to show in marketplace
      provider = create(:user)
      get market_provider_path(provider)
      expect(response).to have_http_status(:success)
    end
  end

end
