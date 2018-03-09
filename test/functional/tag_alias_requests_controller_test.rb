require 'test_helper'

class TagAliasRequestsControllerTest < ActionDispatch::IntegrationTest
  context "The tag alias request controller" do
    setup do
      @user = FactoryBot.create(:user)
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

    context "create action" do
      should "render" do
        assert_difference("ForumTopic.count", 1) do
          post_authenticated :create:_path, @user, params: {:tag_alias_request => {:antecedent_name => "aaa", :consequent_name => "bbb", :reason => "ccc", :skip_secondary_validations => true}}
        end
        assert_redirected_to(forum_topic_path(ForumTopic.last))
      end
    end
  end
end
