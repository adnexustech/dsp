require 'rails_helper'

RSpec.describe Bidder, type: :model do
  let(:crosstalk_host) { "localhost" }
  let(:crosstalk_port) { "8888" }
  let(:campaign_id) { "123" }
  let(:regions) { "us-east,us-west" }

  before do
    stub_const("RTB_CROSSTALK_REGION_HOSTS", {
      "us-east" => "bidder1.example.com",
      "us-west" => "bidder2.example.com"
    })
    stub_const("RTB_CROSSTALK_PORT", "8888")
    stub_const("RTB_CROSSTALK_USER", "test_user")
    stub_const("RTB_CROSSTALK_PASSWORD", "test_password")
  end

  describe ".ping" do
    context "when bidder is reachable" do
      before do
        stub_request(:post, "http://bidder1.example.com:8888/api")
          .with(
            body: hash_including(
              "type" => "Ping#",
              "username" => "test_user",
              "password" => "test_password"
            )
          )
          .to_return(status: 200, body: "OK")
      end

      it "returns 'ok'" do
        expect(Bidder.ping).to eq("ok")
      end

      it "makes HTTP POST request to all crosstalk hosts" do
        Bidder.ping
        
        expect(WebMock).to have_requested(:post, "http://bidder1.example.com:8888/api")
          .once
      end
    end

    context "when bidder is unreachable" do
      before do
        stub_request(:post, "http://bidder1.example.com:8888/api")
          .to_timeout
      end

      it "returns nil" do
        expect(Bidder.ping).to be_nil
      end
    end
  end

  describe ".updateCampaign" do
    context "with specific regions" do
      before do
        stub_request(:post, "http://bidder1.example.com:8888/api")
          .with(
            body: hash_including(
              "type" => "Update#",
              "campaign" => campaign_id,
              "async" => true
            )
          )
          .to_return(status: 200, body: '{"status":"ok"}')

        stub_request(:post, "http://bidder2.example.com:8888/api")
          .to_return(status: 200, body: '{"status":"ok"}')
      end

      it "sends update to specified regions" do
        Bidder.updateCampaign(campaign_id, regions)

        expect(WebMock).to have_requested(:post, "http://bidder1.example.com:8888/api")
          .with(body: hash_including("campaign" => campaign_id))
          .once
        
        expect(WebMock).to have_requested(:post, "http://bidder2.example.com:8888/api")
          .with(body: hash_including("campaign" => campaign_id))
          .once
      end
    end

    context "without specific regions (broadcast to all)" do
      before do
        stub_request(:post, "http://bidder1.example.com:8888/api")
          .to_return(status: 200, body: '{"status":"ok"}')
        stub_request(:post, "http://bidder2.example.com:8888/api")
          .to_return(status: 200, body: '{"status":"ok"}')
      end

      it "sends update to all regions" do
        Bidder.updateCampaign(campaign_id, nil)

        expect(WebMock).to have_requested(:post, "http://bidder1.example.com:8888/api")
        expect(WebMock).to have_requested(:post, "http://bidder2.example.com:8888/api")
      end
    end

    context "when bidder returns error" do
      before do
        stub_request(:post, "http://bidder1.example.com:8888/api")
          .to_return(status: 500, body: "Internal Server Error")
      end

      it "returns nil" do
        result = Bidder.updateCampaign(campaign_id, "us-east")
        expect(result).to be_nil
      end
    end
  end

  describe ".deleteCampaign" do
    before do
      stub_request(:post, "http://bidder1.example.com:8888/api")
        .with(
          body: hash_including(
            "type" => "Delete#",
            "campaign" => campaign_id
          )
        )
        .to_return(status: 200, body: '{"status":"ok"}')
    end

    it "sends delete command to bidder" do
      Bidder.deleteCampaign(campaign_id, "us-east")

      expect(WebMock).to have_requested(:post, "http://bidder1.example.com:8888/api")
        .with(body: hash_including("type" => "Delete#", "campaign" => campaign_id))
    end
  end

  describe ".updateAll" do
    before do
      stub_request(:post, "http://bidder1.example.com:8888/api")
        .with(body: hash_including("type" => "Refresh#"))
        .to_return(status: 200, body: "OK")
      stub_request(:post, "http://bidder2.example.com:8888/api")
        .with(body: hash_including("type" => "Refresh#"))
        .to_return(status: 200, body: "OK")
    end

    it "sends refresh command to all bidders" do
      Bidder.updateAll

      expect(WebMock).to have_requested(:post, "http://bidder1.example.com:8888/api")
        .with(body: hash_including("type" => "Refresh#"))
      expect(WebMock).to have_requested(:post, "http://bidder2.example.com:8888/api")
        .with(body: hash_including("type" => "Refresh#"))
    end
  end

  describe ".loadS3" do
    let(:settype) { "blacklist" }
    let(:name) { "test_blacklist" }
    let(:s3path) { "s3://bucket/path/to/file.csv" }

    before do
      stub_request(:post, "http://bidder1.example.com:8888/api")
        .to_return(status: 200, body: "OK")
      stub_request(:post, "http://bidder2.example.com:8888/api")
        .to_return(status: 200, body: "OK")
    end

    it "sends S3 load command to bidders" do
      Bidder.loadS3(settype, name, s3path)

      expect(WebMock).to have_requested(:post, "http://bidder1.example.com:8888/api")
        .with(body: hash_including(
          "type" => "ConfigureAws#",
          "command" => "load S3 #{settype} #{name} #{s3path}"
        ))
    end
  end

  describe "error handling" do
    context "when network timeout occurs" do
      before do
        stub_request(:post, "http://bidder1.example.com:8888/api")
          .to_timeout
      end

      it "logs error and returns nil" do
        expect(Rails.logger).to receive(:error).with(/Exception error/)
        result = Bidder.updateCampaign(campaign_id, "us-east")
        expect(result).to be_nil
      end
    end

    context "when connection refused" do
      before do
        stub_request(:post, "http://bidder1.example.com:8888/api")
          .to_raise(Errno::ECONNREFUSED)
      end

      it "handles exception gracefully" do
        expect(Rails.logger).to receive(:error).with(/Exception error/)
        result = Bidder.updateCampaign(campaign_id, "us-east")
        expect(result).to be_nil
      end
    end
  end
end
