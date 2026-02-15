require 'rails_helper'

RSpec.describe "Attachments", type: :request do
  before { setup_authentication }

  describe "GET /attachments" do
    it "returns success" do
      get attachments_path
      expect(response).to have_http_status(:success)
    end
  end
end
