require 'rails_helper'

RSpec.describe "Organizations", type: :request do
  before { setup_authentication }

  describe "GET /organization" do
    it "returns http success" do
      get organization_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /organization" do
    it "returns http success" do
      patch organization_path, params: { organization: { name: "Updated Org" } }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "POST /organizations/:id/switch" do
    it "returns http success" do
      org = create(:organization, owner: @test_user)
      post switch_organization_path(org)
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET /organization/members" do
    it "returns http success" do
      get members_organization_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /organization/add_member" do
    it "returns http success" do
      member = create(:user)
      post add_member_organization_path, params: { user_id: member.id }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "DELETE /organization/remove_member" do
    it "returns http success" do
      member = create(:user)
      delete remove_member_organization_path, params: { user_id: member.id }
      expect(response).to have_http_status(:redirect)
    end
  end

end
