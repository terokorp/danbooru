require 'test_helper'

class PostFlagsControllerTest < ActionDispatch::IntegrationTest
  context "The post flags controller" do
    setup do
      Timecop.travel(2.weeks.ago) do
        @user = FactoryBot.create(:user)
      end
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "new action" do
      should "render" do
        get :new, {}, {:user_id => @user.id}
        assert_response :success
      end
    end

    context "index action" do
      setup do
        @post = FactoryBot.create(:post)
        @post_flag = FactoryBot.create(:post_flag, :post => @post)
      end

      should "render" do
        get :index, {}, {:user_id => @user.id}
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          get_authenticated :index:_path, @user, params: {:search => {:post_id => @post_flag.post_id}}
          assert_response :success
        end
      end
    end

    context "create action" do
      setup do
        @post = FactoryBot.create(:post)
      end

      should "create a new flag" do
        assert_difference("PostFlag.count", 1) do
          post_authenticated :create:_path, @user, params: {:format => "js", :post_flag => {:post_id => @post.id, :reason => "xxx"}}
          assert_not_nil(assigns(:post_flag))
          assert_equal([], assigns(:post_flag).errors.full_messages)
        end
      end
    end
  end
end
