require 'test_helper'

class UploadsControllerTest < ActionDispatch::IntegrationTest
  def setup
    super
    mock_iqdb_service!
  end

  context "The uploads controller" do
    setup do
      @user = FactoryBot.create(:contributor_user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "batch action" do
      context "for twitter galleries" do
        should "render" do
          get_authenticated :batch:_path, @user, params: {:url => "https://twitter.com/lvlln/status/567054278486151168"}
          assert_response :success
        end
      end

      context "for pixiv ugoira galleries" do
        should "render" do
          get_authenticated :batch:_path, @user, params: {:url => "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=59523577"}
          assert_response :success
          assert_no_match(/59523577_ugoira0\.jpg/, response.body)
        end
      end
    end

    context "new action" do
      should "render" do
        get :new, {}, {:user_id => @user.id}
        assert_response :success
      end

      context "for a twitter post" do
        setup do
          get_authenticated :new:_path, @user, params: {:url => "https://twitter.com/frappuccino/status/566030116182949888"}
        end

        should "render" do
          assert_response :success
        end
      end

      context "for a post that has already been uploaded" do
        setup do
          @post = FactoryBot.create(:post, :source => "aaa")
        end

        should "initialize the post" do
          get_authenticated :new:_path, @user, params: {:url => "aaa"}
          assert_response :success
          assert_not_nil(assigns(:post))
        end
      end
    end

    context "index action" do
      setup do
        @upload = FactoryBot.create(:source_upload)
      end

      should "render" do
        get :index, {}, {:user_id => @user.id}
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          get_authenticated :index:_path, @user, params: {:search => {:source => @upload.source}}
          assert_response :success
        end
      end
    end

    context "show action" do
      setup do
        @upload = FactoryBot.create(:jpg_upload)
      end

      should "render" do
        get_authenticated :show:_path, @user, params: {:id => @upload.id}
        assert_response :success
      end
    end

    context "create action" do
      should "create a new upload" do
        assert_difference("Upload.count", 1) do
          file = Rack::Test::UploadedFile.new("#{Rails.root}/test/files/test.jpg", "image/jpeg")
          file.stubs(:tempfile).returns(file)
          post_authenticated :create:_path, @user, params: {:upload => {:file => file, :tag_string => "aaa", :rating => "q", :source => "aaa"}}
        end
      end
    end

    context "update action" do
      setup do
        @upload = FactoryBot.create(:jpg_upload)
      end

      should "process an unapproval" do
        post_authenticated :update:_path, @user, params: {:id => @upload.id}
        @upload.reload
        assert_equal("completed", @upload.status)
      end
    end
  end
end
