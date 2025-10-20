require 'rails_helper'

RSpec.describe "Documents", type: :request do
  before do
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_return(true)
  end

  describe "GET /documents" do
    it "returns success" do
      get documents_path
      expect(response).to have_http_status(:success)
    end
  end
end
