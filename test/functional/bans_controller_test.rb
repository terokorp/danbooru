require 'test_helper'

class BansControllerTest < ActionController::TestCase
  context "A bans controller" do
    setup do
      @mod = FactoryBot.create(:moderator_user)
      CurrentUser.user = @mod
      CurrentUser.ip_addr = "127.0.0.1"
      @user = FactoryBot.create(:user)
      @ban = FactoryBot.create(:ban, :user_id => @user.id)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "get the new page" do
      session[:user_id] = @mod.id
      get :new
      assert_response :success
    end

    should "get the edit page" do
      session[:user_id] = @mod.id
      get :edit, params: {id: @ban.id}
      assert_response :success
    end

    should "get the show page" do
      get :show, params: {id: @ban.id}
      assert_response :success
    end

    should "get the index page" do
      get :index
      assert_response :success
    end

    should "search" do
      get :index, params: {search: {user_name: @user.name}}
      assert_response :success
    end

    should "create a ban" do
      assert_difference("Ban.count", 1) do
        session[:user_id] = @mod.id
        post :create, params: {ban: {duration: 60, reason: "xxx", user_id: @user.id}}
      end
      ban = Ban.last
      assert_redirected_to(ban_path(ban))
    end

    should "update a ban" do
      session[:user_id] = @mod.id
      post :update, params: {id: @ban.id, ban: {reason: "xxx", duration: 60}}
      @ban.reload
      assert_equal("xxx", @ban.reason)
      assert_redirected_to(ban_path(@ban))
    end

    should "destroy a ban" do
      assert_difference("Ban.count", -1) do
        session[:user_id] = @mod.id
        post :destroy, params: {id: @ban.id}
      end
      assert_redirected_to(bans_path)
    end
  end
end
