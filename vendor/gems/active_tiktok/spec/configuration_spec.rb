RSpec.describe ActiveTiktok::Configuration do
  subject(:config) { described_class.new }

  describe '#initialize' do
    it 'initializes with an empty providers array' do
      expect(config.providers).to eq([])
    end
  end

  describe '#add_provider' do
    let(:driver) { 'chrome' }
    let(:api_key) { 'secret_api_key' }
    let(:account_key) { 'secret_account_key' }

    before do
      config.add_provider(provider: driver, api_key: api_key, account_key: account_key)
    end

    it 'adds a provider to the providers array' do
      expect(config.providers).not_to be_empty
    end

    it 'stores the provider as a hash with driver and api_key' do
      expect(config.providers.first).to eq({ provider: driver, api_key: api_key, account_key: account_key })
    end

    it 'increases the providers array size by 1' do
      expect { config.add_provider(provider: 'firefox', api_key: 'another_secret_key', account_key: account_key) }.to change { config.providers.size }.by(1)
    end
  end
end
