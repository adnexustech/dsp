require 'rails_helper'

RSpec.describe "Lists", type: :request do
  before { setup_authentication }

  describe "GET /lists" do
    it "returns success" do
      get lists_path
      expect(response).to have_http_status(:success)
    end
  end
end
