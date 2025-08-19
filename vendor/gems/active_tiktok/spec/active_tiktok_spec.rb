# frozen_string_literal: true

RSpec.describe ActiveTiktok do
  before do
    described_class.configure do |config|
      config.add_provider(provider: 'tikapi', api_key: 'oke', account_key: 'ake')
      config.add_provider(provider: 'tokapi_mobile', api_key: 'oke')
    end
  end
  it "has a version number" do
    expect(ActiveTiktok::VERSION).not_to be nil
  end

  it 'can be configured' do
    expect(described_class.configuration.providers.size).to eq(2)
  end

  it 'calls client media_by_id' do
    client = double('client', media_by_id: nil)
    allow(ActiveTiktok::Client).to receive(:new).with(described_class.configuration).and_return(client)

    expect(client).to receive(:media_by_id).with('12345')

    described_class.media_by_id('12345')
  end

  it 'calls client comments_by_media_id' do
    client = double('client', comments_by_media_id: nil)
    allow(ActiveTiktok::Client).to receive(:new).with(described_class.configuration).and_return(client)

    expect(client).to receive(:comments_by_media_id).with('12345', 0)

    described_class.comments_by_media_id('12345')
  end
end
