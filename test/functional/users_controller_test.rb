require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  context "The users controller" do
    setup do
      @user = FactoryBot.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
    end

    context "index action" do
      should "list all users" do
        get :index
        assert_response :success
      end

      should "list all users for /users?name=<name>" do
        get :index, { name: @user.name }
        assert_redirected_to(@user)
      end

      should "raise error for /users?name=<nonexistent>" do
        get :index, { name: "nobody" }
        assert_response :error
      end

      should "list all users (with search)" do
        get :index, {:search => {:name_matches => @user.name}}
        assert_response :success
      end
    end

    context "show action" do
      setup do
        # flesh out profile to get more test coverage of user presenter.
        @user = FactoryBot.create(:banned_user, can_approve_posts: true, is_super_voter: true)
        FactoryBot.create(:saved_search, user: @user)
        FactoryBot.create(:post, uploader: @user, tag_string: "fav:#{@user.name}")
      end

      should "render" do
        get :show, {:id => @user.id}
        assert_response :success
      end

      should "show hidden attributes to the owner" do
        get_authenticated :show:_path, @user, params: {id: @user.id, format: :json}
        json = JSON.parse(response.body)

        assert_response :success
        assert_not_nil(json["last_logged_in_at"])
      end

      should "not show hidden attributes to others" do
        another = FactoryBot.create(:user)

        get_authenticated :show:_path, @user, params: {id: another.id, format: :json}
        json = JSON.parse(response.body)

        assert_response :success
        assert_nil(json["last_logged_in_at"])
      end

      should "strip '?' from attributes" do
        get_authenticated :show:_path, @user, params: {id: @user.id, format: :xml}
        xml = Hash.from_xml(response.body)

        assert_response :success
        assert_equal(false, xml["user"]["can_upload"])
      end
    end

    context "new action" do
      setup do
        Danbooru.config.stubs(:enable_recaptcha?).returns(false)
      end
      
      should "render" do
        get :new
        assert_response :success
      end
    end

    context "create action" do
      should "create a user" do
        assert_difference("User.count", 1) do
          post_authenticated :create:_path, @user, params: {:user => {:name => "xxx", :password => "xxxxx1", :password_confirmation => "xxxxx1"}}
          assert_not_nil(assigns(:user))
          assert_equal([], assigns(:user).errors.full_messages)
        end
      end

      should "not allow registering multiple accounts with the same IP" do
        Danbooru.config.unstub(:enable_sock_puppet_validation?)
        request.env["REMOTE_ADDR"] = "1.2.3.4"
        CurrentUser.user = nil

        post :create, {:user => {:name => "user", :password => "xxxxx1", :password_confirmation => "xxxxx1"}}, {}
        session.clear
        post :create, {:user => {:name => "dupe", :password => "xxxxx1", :password_confirmation => "xxxxx1"}}, {}

        assert_equal(true, User.where(name: "user").exists?)
        assert_equal(false, User.where(name: "dupe").exists?)

        assert_equal(IPAddr.new("1.2.3.4"), User.find_by_name("user").last_ip_addr)
        assert_match(/Sign up failed: Last ip addr was used recently/, flash[:notice])
      end
    end

    context "edit action" do
      setup do
        @user = FactoryBot.create(:user)
      end

      should "render" do
        get_authenticated :edit:_path, @user, params: {:id => @user.id}
        assert_response :success
      end
    end

    context "update action" do
      setup do
        @user = FactoryBot.create(:user)
      end

      should "update a user" do
        post_authenticated :update:_path, @user, params: {:id => @user.id, :user => {:favorite_tags => "xyz"}}
        @user.reload
        assert_equal("xyz", @user.favorite_tags)
      end

      context "changing the level" do
        setup do
          @cuser = FactoryBot.create(:user)
        end

        should "not work" do
          post_authenticated :update:_path, @cuser, params: {:id => @user.id, :user => {:level => 40}}
          @user.reload
          assert_equal(20, @user.level)
        end
      end

      context "for a banned user" do
        should "allow the user to edit their settings" do
          @user = FactoryBot.create(:banned_user)
          post_authenticated :update:_path, @user, params: {:id => @user.id, :user => {:favorite_tags => "xyz"}}

          assert_equal("xyz", @user.reload.favorite_tags)
        end
      end
    end
  end
end
