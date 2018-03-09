require 'test_helper'

module Moderator
  class IpAddrsControllerTest < ActionDispatch::IntegrationTest
    context "The ip addrs controller" do
      setup do
        PoolArchive.delete_all
        PostArchive.delete_all
        
        @user = FactoryBot.create(:moderator_user)
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"
        FactoryBot.create(:comment)
      end

      teardown do
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end

      should "find by ip addr" do
        get_authenticated :index:_path, @user, params: {:search => {:ip_addr => "127.0.0.1"}}
        assert_response :success
      end

      should "find by user id" do
        get_authenticated :index:_path, @user, params: {:search => {:user_id => @user.id.to_s}}
        assert_response :success
      end

      should "find by user name" do
        get_authenticated :index:_path, @user, params: {:search => {:user_name => @user.name}}
        assert_response :success
      end

      should "render the search page" do
        get :search, {}, {:user_id => @user.id}
        assert_response :success
      end
    end
  end
end
