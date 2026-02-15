require 'rails_helper'

RSpec.describe "RtbStandards", type: :request do
  before { setup_authentication }

  describe "GET /rtb_standards" do
    it "returns success" do
      get rtb_standards_path
      expect(response).to have_http_status(:success)
    end
  end
end
