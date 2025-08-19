require "active_instagram/configuration"

RSpec.describe ActiveInstagram::Configuration do
  describe "#initialize" do
    it "sets the api_key and driver attributes" do
      config = described_class.new(api_key: "your_api_key", driver: :hikerapi)

      expect(config.api_key).to eq("your_api_key")
      expect(config.driver).to eq(:hikerapi)
    end
  end

  describe "attr_accessor" do
    it "allows getting and setting the api_key attribute" do
      config = described_class.new
      config.api_key = "your_api_key"

      expect(config.api_key).to eq("your_api_key")
    end

    it "allows getting and setting the driver attribute" do
      config = described_class.new
      config.driver = :hikerapi

      expect(config.driver).to eq(:hikerapi)
    end
  end
end
