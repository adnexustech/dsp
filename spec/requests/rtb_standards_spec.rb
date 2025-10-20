require 'rails_helper'

RSpec.describe "RtbStandards", type: :request do
  before do
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_return(true)
  end

  describe "GET /rtb_standards" do
    it "returns success" do
      get rtb_standards_path
      expect(response).to have_http_status(:success)
    end
  end
end
