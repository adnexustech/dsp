require 'rails_helper'

RSpec.describe "Organizations", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/organizations/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/organizations/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /switch" do
    it "returns http success" do
      get "/organizations/switch"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /members" do
    it "returns http success" do
      get "/organizations/members"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /add_member" do
    it "returns http success" do
      get "/organizations/add_member"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /remove_member" do
    it "returns http success" do
      get "/organizations/remove_member"
      expect(response).to have_http_status(:success)
    end
  end

end
