# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Referrals", type: :request do
  let(:user) { create(:user) }

  describe "GET /referrals" do
    context "when user is authenticated" do
      before { setup_authentication }

      it "returns http success" do
        get referrals_path
        expect(response).to have_http_status(:success)
      end

      it "returns 200 status code" do
        get referrals_path
        expect(response.status).to eq(200)
      end

      it "does not redirect to login" do
        get referrals_path
        expect(response).not_to redirect_to('/login')
      end
    end

    context "when user is not authenticated" do
      before do
        # Ensure no user is logged in
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
      end

      it "redirects to login page" do
        get referrals_path
        expect(response).to redirect_to('/login')
      end

      it "returns http redirect status" do
        get referrals_path
        expect(response).to have_http_status(:redirect)
      end

      it "returns 302 status code" do
        get referrals_path
        expect(response.status).to eq(302)
      end

      it "does not return success status" do
        get referrals_path
        expect(response).not_to have_http_status(:success)
      end
    end
  end

  describe "authorization behavior" do
    context "with authenticated user via stub" do
      before { setup_authentication }

      it "allows access to authenticated user" do
        get referrals_path
        expect(response).to have_http_status(:success)
      end

      it "does not redirect authenticated user" do
        get referrals_path
        expect(response).not_to be_redirect
      end
    end

    context "without authenticated user" do
      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
      end

      it "denies access and redirects" do
        get referrals_path
        expect(response).to redirect_to('/login')
      end

      it "does not allow unauthenticated access" do
        get referrals_path
        expect(response).not_to have_http_status(:success)
      end
    end
  end
end
