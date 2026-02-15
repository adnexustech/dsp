require 'rails_helper'

RSpec.describe "Help", type: :request do
  before { setup_authentication }

  describe "GET /help" do
    it "returns success" do
      get help_path
      expect(response).to have_http_status(:success)
    end
  end
end
