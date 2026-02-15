require 'rails_helper'

RSpec.describe "Users", type: :request do
  before { setup_authentication }

  describe "GET /users" do
    it "returns success" do
      get users_path
      expect(response).to have_http_status(:success)
    end
  end
end
