require 'test_helper'

class PostEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Timecop.travel(2.weeks.ago) do
      @user = create(:user)
    end

    CurrentUser.as(@user) do
      @post = create(:post)
      @post_flag = PostFlag.create(:post => @post, :reason => "aaa", :is_resolved => false)
      @post_appeal = PostAppeal.create(:post => @post, :reason => "aaa")
    end
  end

  context "GET /posts/:post_id/events" do
    should "render" do
      get :index, {:post_id => @post.id}, {:user_id => CurrentUser.user.id}
      assert_response :ok      
    end

    should "render for mods" do
      get :index, {:post_id => @post.id}, {:user_id => create(:moderator_user).id }
      assert_response :success
    end
  end

  context "GET /posts/:post_id/events.xml" do
    setup do
      get :index, {:post_id => @post.id, :format => :xml}, {:user_id => CurrentUser.user.id}

      @xml = Hash.from_xml(response.body)
      @appeal = @xml["post_events"].find { |e| e["type"] == "a" }
    end

    should "render" do
      assert_not_nil(@appeal)
    end

    should "return is_resolved correctly" do
      assert_equal(false, @appeal["is_resolved"])
    end
  end
end
