require 'rails_helper'

RSpec.describe "Markets", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/market/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/market/show"
      expect(response).to have_http_status(:success)
    end
  end

end
