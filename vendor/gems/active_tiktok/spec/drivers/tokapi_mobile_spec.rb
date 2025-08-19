RSpec.describe ActiveTiktok::Drivers::TokapiMobile do
  let(:tokapi_mobile) { described_class.new(api_key: 'xxx') }

  describe '#media_by_id' do
    it 'returns media model' do
      VCR.use_cassette('tokapi_mobile_media_by_id') do
        media = tokapi_mobile.media_by_id('7172051470618037530')

        expect(media).to be_instance_of(ActiveTiktok::Models::Media)
        expect(media.id).to eq('7172051470618037530')
        expect(media.post_identifier).to eq('7172051470618037530')
        expect(media.caption).to eq('selama umroh kemarin, ga lupa nyari² anabul buat di wawancara..  pertanyaannya seputar:  1. berapa lama tinggal disini?  2. suka duka nya apa aja?  #gadenkcandabgt ')
        expect(media.post_created_at).to eq(1669873365)
        expect(media.likes_count).to eq(567)
        expect(media.comments_count).to eq(18)
        expect(media.shares_count).to eq(10)
        expect(media.impressions).to eq(7455)
        expect(media.reach).to eq(7455)
        expect(media.engagement_rate).to eq(7.981220657276995)
        expect(media.cover).to eq('https://p16-sign-useast2a.tiktokcdn.com/tos-useast2a-p-0037-aiso/o4XKCeIDVPQbp56YPQCDSQ5iIAMjEWnW9HtDeB~c5_300x400.jpeg?lk3s=d05b14bd&nonce=79271&refresh_token=005b920bdf3041eb95bea6c3a65c3369&x-expires=1720785600&x-signature=J6rC%2BlGIl4kac6GhzxNhcBMQdng%3D&s=AWEME_DETAIL&se=false&sh=&sc=cover&l=202407111208428E091BA28D714B214C6A&shp=d05b14bd&shcp=-')
        expect(media.payload).to be_instance_of(Hash)
      end
    end

    describe 'error handling' do
      context 'when resource is not found' do
        it 'raises MediaNotFoundError' do
          url = "https://tokapi-mobile-version.p.rapidapi.com/v1/post/7283051601231678725"

          stub_request(:get, url)
            .to_return(status: 403, body: '"{"extra":{"fatal_item_ids":[],"logid":"202407111216268A9907D5AA2F8222E1D0","now":1720700187000},"log_pb":{"impr_id":"202407111216268A9907D5AA2F8222E1D0"},"status_code":0,"status_msg":""}"')

          expect { tokapi_mobile.media_by_id('7283051601231678725') }.to raise_error(ActiveTiktok::Drivers::MediaNotFoundError)
        end

        it 'raises MediaNotFoundError' do
          url = "https://tokapi-mobile-version.p.rapidapi.com/v1/post/okeaasdadasdasdaddadad"

          stub_request(:get, url)
            .to_return(status: 403, body: '"{"log_pb":{"impr_id":"202407111223088218BF06C303D0221D87"},"status_code":5,"status_msg":"Invalid parameters"}"')

          expect { tokapi_mobile.media_by_id('okeaasdadasdasdaddadad') }.to raise_error(ActiveTiktok::Drivers::MediaNotFoundError)
        end
      end
    end
  end

  describe '#comments_by_media_id' do
    before(:all) do
      VCR.use_cassette('tokapi_mobile_comments_by_media_id') do
        tokapi = described_class.new(api_key: 'xxx')
        @comments_collection = tokapi.comments_by_media_id('7172051470618037530')
      end
    end

    it 'returns CommentsCollection' do
      expect(@comments_collection).to be_instance_of(ActiveTiktok::Models::CommentsCollection)
    end

    it 'returns comment model' do
      comment = @comments_collection.comments.first
      expect(comment).to be_instance_of(ActiveTiktok::Models::Comment)
      expect(comment.id).to eq('7173215357107667739')
      expect(comment.text).to eq('smoga bisa kesna juga ksih makan anabul🥰')
      expect(comment.created_at).to eq(1670144361)
      expect(comment.username).to eq('petshop Timbul toabo')
      expect(comment.payload).to be_instance_of(Hash)
      expect(comment.payload).to have_key('text')
    end

    it 'returns empty comments collection' do
      VCR.use_cassette('tokapi_mobile_comments_by_media_id_empty') do
        tokapi_mobile = described_class.new(api_key: 'xxx')
        comments_collection = tokapi_mobile.comments_by_media_id('7339679037096283397')

        expect(comments_collection.comments).to be_empty
        expect(comments_collection.has_more).to eq(false)
        expect(comments_collection.cursor).to eq(0)
      end
    end
  end

  describe '#user_by_username' do
    let(:tokapi_mobile) { described_class.new(api_key: 'xxx') }

    it 'returns user model' do
      VCR.use_cassette('tokapi_mobile_user_by_username_returns_user_model') do
        user = tokapi_mobile.user_by_username('tiktok')
        expect(user).to be_instance_of(ActiveTiktok::Models::User)
      end
    end

    it 'supports username with or without @' do
      VCR.use_cassette('tokapi_mobile_user_by_username_with_or_without_at') do
        user = tokapi_mobile.user_by_username('tiktok')
        expect(user).to be_instance_of(ActiveTiktok::Models::User)

        user2 = tokapi_mobile.user_by_username('@tiktok')
        expect(user2).to be_instance_of(ActiveTiktok::Models::User)
      end
    end

    it 'raises UserNotFoundError' do
      VCR.use_cassette('tokapi_mobile_user_not_found') do
        expect { tokapi_mobile.user_by_username('keluargaburwwwww') }.to raise_error(ActiveTiktok::Drivers::UserNotFoundError)
      end
    end

    it 'populates user model correctly' do
      VCR.use_cassette('tokapi_mobile_user_by_username_populates_user_model_correctly') do
        @user = tokapi_mobile.user_by_username('tiktok')
      end

      expect(@user.username).to eq('tiktok')
      expect(@user.full_name).to eq('TikTok')
      expect(@user.profile_picture).to be_instance_of(String)
      expect(@user.bio).to eq 'bringing the fyp to your feed'
      expect(@user.website).to eq 'linktr.ee/tiktok'
      expect(@user.media_count).to eq(1117)
      expect(@user.follows_count).to eq(1)
      expect(@user.followed_by_count).to eq(82804184)
    end
  end

  describe '#medias_by_user_id' do
    it 'returns medias collection with correct media attributes' do
      VCR.use_cassette('tokapi_mobile_medias_by_user_id') do
        medias_collection = tokapi_mobile.medias_by_user_id('MS4wLjABAAAAr8BhiSmkWNQH0v5SVFCgQnoqUd5_RMsesTVppIiN-LGo6_-VyQxnNx8-U6vBbxHo')

        # Collection level expectations
        expect(medias_collection).to be_instance_of(ActiveTiktok::Models::MediasCollection)
        expect(medias_collection.medias.size).to eq(10)
        expect(medias_collection.user_id).to eq('MS4wLjABAAAAr8BhiSmkWNQH0v5SVFCgQnoqUd5_RMsesTVppIiN-LGo6_-VyQxnNx8-U6vBbxHo')
        expect(medias_collection.has_more).to eq(1)
        expect(medias_collection.cursor).to eq(1727702393000)

        # First media expectations
        first_media = medias_collection.medias.first
        expect(first_media).to be_instance_of(ActiveTiktok::Models::Media)
        expect(first_media.id).to eq('7433049881608064262')
        expect(first_media.post_identifier).to eq('7433049881608064262')
        expect(first_media.caption).to eq('Siapa yang udh dateng ke pucuk coolinary festival?Acara nya bener2 seru, tenant makanannya banyak, ada activity nya juga, dan ada festival musiknya juga! dan yg penting acaranya GRATIS! kira2 selanjutnya pucuk coolinary festival ada dikota mana lagi ya? #MakanBarengPucukBaruEnak #PucukCoolinaryFestival2024 @Teh Pucuk Harum ')
        expect(first_media.post_created_at).to eq(1730641795)
        expect(first_media.likes_count).to eq(39397)
        expect(first_media.comments_count).to eq(332)
        expect(first_media.shares_count).to eq(160)
        expect(first_media.impressions).to eq(577226)
        expect(first_media.reach).to eq(577226)
        expect(first_media.engagement_rate).to eq(6.910464878574424)
        expect(first_media.cover).to eq('https://p16-sign-va.tiktokcdn.com/tos-maliva-p-0068/o0EC0ADiF8geTgn2fj5EACkIp6VQQSIfgOvb7E~tplv-tiktokx-cropcenter:300:400.heic?dr=10399&nonce=32171&refresh_token=50c3fd0348d98c7905d480a7c6d3d1a9&x-expires=1730955600&x-signature=Oo2E3j3TLeobdaYqXxQAgUsEu0s%3D&idc=useast2a&ps=13740610&s=PUBLISH&shcp=34ff8df6&shp=d05b14bd&t=4d5b0474')
        expect(first_media.payload).to be_a(Hash)
      end
    end
  end
end
