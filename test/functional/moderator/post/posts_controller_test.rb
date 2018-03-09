require 'test_helper'

module Moderator
  module Post
    class PostsControllerTest < ActionDispatch::IntegrationTest
      context "The moderator posts controller" do
        setup do
          @admin = FactoryGirl.create(:admin_user)
          CurrentUser.user = @admin
          CurrentUser.ip_addr = "127.0.0.1"
          @post = FactoryGirl.create(:post)
        end

        teardown do
          CurrentUser.user = nil
          CurrentUser.ip_addr = nil
        end

        context "confirm_delete action" do
          should "render" do
            get_authenticated :confirm_delete:_path, @admin, params: { id: @post.id }
            assert_response :success
          end
        end

        context "delete action" do
          should "render" do
            post_authenticated :delete:_path, @admin, params: {:id => @post.id, :reason => "xxx", :format => "js", :commit => "Delete"}
            assert(@post.reload.is_deleted?)
          end

          should "work even if the deleter has flagged the post previously" do
            PostFlag.create(:post => @post, :reason => "aaa", :is_resolved => false)
            post_authenticated :delete:_path, @admin, params: {:id => @post.id, :reason => "xxx", :format => "js", :commit => "Delete"}
            assert(@post.reload.is_deleted?)
          end
        end

        context "undelete action" do
          should "render" do
            @post.update(is_deleted: true)
            post_authenticated :undelete:_path, @admin, params: {:id => @post.id, :format => "js"}

            assert_response :success
            assert(!@post.reload.is_deleted?)
          end
        end

        context "confirm_move_favorites action" do
          should "render" do
            get_authenticated :confirm_move_favorites:_path, @admin, params: { id: @post.id }
            assert_response :success
          end
        end

        context "move_favorites action" do
          setup do
            @admin = FactoryGirl.create(:admin_user)
            CurrentUser.user = @admin
            CurrentUser.ip_addr = "127.0.0.1"
          end

          teardown do
            CurrentUser.user = nil
            CurrentUser.ip_addr = nil
          end

          should "1234 render" do
            parent = FactoryGirl.create(:post)
            child = FactoryGirl.create(:post, parent: parent)
            users = FactoryGirl.create_list(:user, 2)
            users.each { |u| child.add_favorite!(u) }

            put_authenticated :move_favorites:_path, @admin, params: { id: child.id, commit: "Submit" }

            CurrentUser.user = @admin
            assert_redirected_to(child)
            assert_equal(users, parent.reload.favorited_users)
            assert_equal([], child.reload.favorited_users)
          end
        end

        context "expunge action" do
          should "render" do
            put_authenticated :expunge:_path, @admin, params: { id: @post.id, format: "js" }

            assert_response :success
            assert_equal(false, ::Post.exists?(@post.id))
          end
        end

        context "confirm_ban action" do
          should "render" do
            get_authenticated :confirm_ban:_path, @admin, params: { id: @post.id }
            assert_response :success
          end
        end

        context "ban action" do
          should "render" do
            put_authenticated :ban:_path, @admin, params: { id: @post.id, commit: "Ban", format: "js" }

            assert_response :success
            assert_equal(true, @post.reload.is_banned?)
          end
        end

        context "unban action" do
          should "render" do
            @post.ban!
            put_authenticated :unban:_path, @admin, params: { id: @post.id, format: "js" }

            assert_redirected_to(@post)
            assert_equal(false, @post.reload.is_banned?)
          end
        end
      end
    end
  end
end
