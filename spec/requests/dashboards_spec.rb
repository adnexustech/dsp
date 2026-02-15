require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  before { setup_authentication }

  describe "GET /dashboard" do
    it "returns success" do
      get dashboards_path
      expect(response).to have_http_status(:success)
    end
  end
end
