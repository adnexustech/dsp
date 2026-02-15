require 'rails_helper'

RSpec.describe "Documents", type: :request do
  before { setup_authentication }

  describe "GET /documents" do
    it "returns success" do
      get documents_path
      expect(response).to have_http_status(:success)
    end
  end
end
