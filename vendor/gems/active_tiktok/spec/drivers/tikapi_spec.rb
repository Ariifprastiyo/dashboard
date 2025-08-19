RSpec.describe ActiveTiktok::Drivers::Tikapi do
  let(:tikapi) { described_class.new }

  describe '#media_by_id' do
    it 'returns media model' do
      VCR.use_cassette('tikapi_media_by_id') do
        media = tikapi.media_by_id('7172051470618037530')

        expect(media).to be_instance_of(ActiveTiktok::Models::Media)
        expect(media.id).to eq('7172051470618037530')
        expect(media.post_identifier).to eq('7172051470618037530')
        expect(media.caption).to eq('selama umroh kemarin, ga lupa nyari² anabul buat di wawancara..  pertanyaannya seputar:  1. berapa lama tinggal disini?  2. suka duka nya apa aja?  #gadenkcandabgt ')
        expect(media.post_created_at).to eq(1669873365)
        expect(media.likes_count).to eq(567)
        expect(media.comments_count).to eq(17)
        expect(media.shares_count).to eq(10)
        expect(media.impressions).to eq(7455)
        expect(media.reach).to eq(7455)
        expect(media.engagement_rate).to eq(7.967806841046278)
        expect(media.cover).to eq('https://p16-sign-useast2a.tiktokcdn.com/obj/tos-useast2a-p-0037-aiso/3a9a4b8c50a946d3a832cc8596808dd2_1669873375?lk3s=b59d6b55&nonce=34775&refresh_token=1b93487858fd8bb4559f8a649feda5aa&x-expires=1720836000&x-signature=cJD2RkwKNG%2F40o0D5sv%2F7zQXGg8%3D&shp=b59d6b55&shcp=-')
        expect(media.payload).to be_instance_of(Hash)
      end
    end

    describe 'error handling' do
      context 'when resource is not found' do
        it 'raises MediaNotFoundError' do
          url = "https://api.tikapi.io/public/video?id=12345"

          stub_request(:get, url)
            .to_return(status: 403, body: '{"code": 10204, "message": "Media not found"}')

          expect { tikapi.media_by_id('12345') }.to raise_error(ActiveTiktok::Drivers::MediaNotFoundError)
        end

        it 'raises MediaGeneralError' do
          url = "https://api.tikapi.io/public/video?id=12345"

          stub_request(:get, url)
            .to_return(status: 403, body: '{"code": 123, "message": "General error"}')

          expect { tikapi.media_by_id('12345') }.to raise_error(ActiveTiktok::Drivers::MediaGeneralError)
        end
      end
    end
  end

  describe '#comments_by_media_id' do
    before(:all) do
      VCR.use_cassette('tikapi_comments_by_media_id') do
        tikapi = described_class.new(api_key: 'xxx', account_key: 'xxx')
        @comments_collection = tikapi.comments_by_media_id('7172051470618037530')
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
      VCR.use_cassette('tikapi_comments_by_media_id_empty') do
        tikapi = described_class.new(api_key: 'xxx', account_key: 'xxx')
        comments_collection = tikapi.comments_by_media_id('7339679037096283397')

        expect(comments_collection.comments).to be_empty
        expect(comments_collection.has_more).to eq(false)
        expect(comments_collection.cursor).to eq(0)
      end
    end
  end

  describe '#user_by_username' do
    it 'returns user model with exact values' do
      VCR.use_cassette('tikapi_user_by_username') do
        user = tikapi.user_by_username('fadiljaidi')

        expect(user).to be_instance_of(ActiveTiktok::Models::User)
        expect(user.id).to eq('MS4wLjABAAAAr8BhiSmkWNQH0v5SVFCgQnoqUd5_RMsesTVppIiN-LGo6_-VyQxnNx8-U6vBbxHo')
        expect(user.username).to eq('fadiljaidi')
        expect(user.full_name).to eq('Fadil Jaidi')
        expect(user.profile_picture).to eq("https://p16-sign-sg.tiktokcdn.com/aweme/720x720/tos-alisg-avt-0068/7311152514726887425.jpeg?lk3s=a5d48078&nonce=3359&refresh_token=f5aa1abea7ad6eb6b8749a6ca3f854e9&x-expires=1730088000&x-signature=BWJCGBrnqX%2B84F76K%2FXEqdIU2eE%3D&shp=a5d48078&shcp=81f88b70")
        expect(user.bio).to eq("Hai guys\nAku akan post video sama papa diTikTok ya TIDAK di instagramku\nmaacih❤️")
        expect(user.website).to be_nil
        expect(user.media_count).to eq(441)
        expect(user.follows_count).to eq(50)
        expect(user.followed_by_count).to eq(14700000)
      end
    end

    context 'when user is not found' do
      it 'raises UserNotFoundError' do
        VCR.use_cassette('tikapi_user_by_username_not_found') do
          expect { tikapi.user_by_username('fadiljaidi1233475890') }.to raise_error(ActiveTiktok::Drivers::UserNotFoundError)
        end
      end
    end

    context 'supports username with or without @' do
      it 'returns user model' do
        VCR.use_cassette('tikapi_user_by_username_with_or_without_at') do
          user = tikapi.user_by_username('fadiljaidi')
          expect(user).to be_instance_of(ActiveTiktok::Models::User)

          user2 = tikapi.user_by_username('@fadiljaidi')
          expect(user2).to be_instance_of(ActiveTiktok::Models::User)
        end
      end
    end
  end

  describe '#medias_by_user_id' do
    let(:user_id) { 'MS4wLjABAAAAxKGNQEjakF-ZNd8u2pPy2OOE88G8-SLwj4q-M4v8ETU4CDlUYMCm4w54AsXWftKL' }
    let(:medias_collection) do
      VCR.use_cassette('tikapi_medias_by_user_id') do
        tikapi.medias_by_user_id(user_id)
      end
    end

    it 'returns medias collection' do
      expect(medias_collection).to be_instance_of(ActiveTiktok::Models::MediasCollection)
    end

    it 'contains media items' do
      expect(medias_collection.medias.size).to eq(30)
    end

    # Add more test cases as needed
  end
end
