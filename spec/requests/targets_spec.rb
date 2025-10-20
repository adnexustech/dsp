require 'rails_helper'

RSpec.describe "Targets", type: :request do
  before do
    allow_any_instance_of(ApplicationController).to receive(:authorize).and_return(true)
  end

  let(:valid_attributes) do
    {
      name: "Test Target",
      activate_time: Time.now,
      expire_time: Time.now + 30.days
    }
  end

  describe "GET /targets" do
    it "returns success" do
      get targets_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /targets" do
    it "creates a new Target" do
      list = create(:list)
      attributes = valid_attributes.merge(domains_list_id: list.id)
      expect {
        post targets_path, params: { target: attributes }
      }.to change(Target, :count).by(1)
    end
  end

  describe "DELETE /targets/:id" do
    it "destroys the requested target" do
      target = create(:target)
      expect {
        delete target_path(target)
      }.to change(Target, :count).by(-1)
    end
  end
end
