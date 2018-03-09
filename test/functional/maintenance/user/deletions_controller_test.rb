require "test_helper"

module Maintenance
  module User
    class DeletionsControllerTest < ActionDispatch::IntegrationTest
      context "in all cases" do
        setup do
          @user = FactoryGirl.create(:user)
          CurrentUser.user = @user
          CurrentUser.ip_addr = "127.0.0.1"
        end

        context "#show" do
          should "render" do
            get :show, {}, {:user_id => @user.id}
            assert_response :success
          end
        end

        context "#destroy" do
          should "render" do
            post_authenticated :destroy:_path, @user, params: {:password => "password"}
            assert_redirected_to(posts_path)
          end
        end
      end
    end
  end
end