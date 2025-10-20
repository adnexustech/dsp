require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /login" do
    it "returns success" do
      get login_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /login" do
    let(:user) { create(:user, password: "password123", password_confirmation: "password123") }

    it "logs in with valid credentials" do
      post login_path, params: { email: user.email, password: "password123" }
      expect(response).to redirect_to(root_path)
    end

    it "fails with invalid credentials" do
      post login_path, params: { email: user.email, password: "wrong" }
      expect(response).to redirect_to(login_path)
    end
  end

  describe "DELETE /logout" do
    it "logs out the user" do
      delete logout_path
      expect(response).to redirect_to(login_path)
    end
  end
end
