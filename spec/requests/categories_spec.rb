require 'rails_helper'

RSpec.describe "Categories", type: :request do
  before { setup_authentication }

  describe "GET /categories" do
    it "returns success" do
      get categories_path
      expect(response).to have_http_status(:success)
    end
  end
end
