require 'test_helper'

module Moderator
  module Post
    class ApprovalsControllerTest < ActionDispatch::IntegrationTest
      context "The moderator post approvals controller" do
        setup do
          @admin = FactoryGirl.create(:admin_user)
          CurrentUser.user = @admin
          CurrentUser.ip_addr = "127.0.0.1"

          @post = FactoryGirl.create(:post, :is_pending => true)
        end

        context "create action" do
          should "render" do
            post_authenticated :create:_path, @admin, params: {:post_id => @post.id, :format => "js"}
            assert_response :success
            @post.reload
            assert(!@post.is_pending?)
          end
        end
      end
    end
  end
end
