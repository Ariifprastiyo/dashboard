RSpec.describe ActiveTiktok::Client do
  let(:config) do
    ActiveTiktok::Configuration.new(providers)
  end

  let(:providers) do
    [
      { provider: :tikapi, api_key: 'api_key' },
      { provider: :tokapi_mobile, api_key: 'api_key' }
    ]
  end

  let(:client) { described_class.new(config) }

  describe '#initialize' do
    it 'initializes with a config' do
      expect(client).to be_a(described_class)
    end

    it 'stores the drivers' do
      expect(client.drivers.size).to eq(2)
    end

    it 'returns all the drivers' do
      client.drivers.each do |driver|
         expect(driver).to be_a(ActiveTiktok::Drivers::Base)
       end
    end
  end

  describe '#media_by_id' do
    let(:code) { '12345' }
    let(:main_driver) { client.drivers.first }

    it 'calls media_by_id using the first driver' do
      expect(main_driver).to receive(:media_by_id).with(code).once
      client.media_by_id(code)
    end

    context 'when configured with a single driver' do
      let(:single_provider_client) { described_class.new(ActiveTiktok::Configuration.new([providers.first])) }
      let(:main_driver) { single_provider_client.drivers.first }

      it 'does not call the second driver' do
        allow(main_driver).to receive(:media_by_id).with(code).and_raise("Network error")

        expect { single_provider_client.media_by_id(code) }.to raise_error("Network error")
      end
    end

    it 'falls back to the secondary driver when the first driver fails' do
      allow(main_driver).to receive(:media_by_id).with(code).and_raise("Network error")
      expect(client.drivers[1]).to receive(:media_by_id).with(code)
      client.media_by_id(code)
    end
  end

  describe '#comments_by_media_id' do
    let(:code) { '12345' }
    let(:cursor) { 0 }
    let(:main_driver) { client.drivers.first }

    it 'calls comments_by_media_id using the first driver' do
      expect(main_driver).to receive(:comments_by_media_id).with(code, cursor).once
      client.comments_by_media_id(code, cursor)
    end

    context 'when configured with a single driver' do
      let(:single_provider_client) { described_class.new(ActiveTiktok::Configuration.new([providers.first])) }
      let(:main_driver) { single_provider_client.drivers.first }

      it 'does not call the second driver' do
        allow(main_driver).to receive(:comments_by_media_id).with(code, cursor).and_raise("Network error")

        expect { single_provider_client.comments_by_media_id(code, cursor) }.to raise_error("Network error")
      end
    end

    it 'falls back to the secondary driver when the first driver fails' do
      allow(main_driver).to receive(:comments_by_media_id).with(code, cursor).and_raise("Network error")
      expect(client.drivers[1]).to receive(:comments_by_media_id).with(code, cursor)
      client.comments_by_media_id(code, cursor)
    end
  end
end
