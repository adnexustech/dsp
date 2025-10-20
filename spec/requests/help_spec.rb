require 'rails_helper'

RSpec.describe "Help", type: :request do
  before do
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_return(true)
  end

  describe "GET /help" do
    it "returns success" do
      get help_index_path
      expect(response).to have_http_status(:success)
    end
  end
end
