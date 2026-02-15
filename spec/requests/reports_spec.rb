require 'rails_helper'

RSpec.describe "Reports", type: :request do
  before { setup_authentication }

  describe "GET /reports" do
    it "returns success" do
      get reports_path
      expect(response).to have_http_status(:success)
    end
  end
end
