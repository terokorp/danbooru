require 'test_helper'

class UserFeedbacksControllerTest < ActionDispatch::IntegrationTest
  context "The user feedbacks controller" do
    setup do
      @user = FactoryBot.create(:user)
      @critic = FactoryBot.create(:gold_user)
      @mod = FactoryBot.create(:moderator_user)
      CurrentUser.user = @critic
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "new action" do
      should "render" do
        get_authenticated :new:_path, @critic, params: { user_feedback: { user_id: @user.id } }
        assert_response :success
      end
    end

    context "edit action" do
      setup do
        @user_feedback = FactoryBot.create(:user_feedback)
      end

      should "render" do
        get_authenticated :edit:_path, @critic, params: {:id => @user_feedback.id}
        assert_response :success
      end
    end

    context "index action" do
      setup do
        @user_feedback = FactoryBot.create(:user_feedback)
      end

      should "render" do
        get :index, {}, {:user_id => @user.id}
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          get_authenticated :index:_path, @critic, params: {:search => {:user_id => @user.id}}
          assert_response :success
        end
      end
    end

    context "create action" do
      should "create a new feedback" do
        assert_difference("UserFeedback.count", 1) do
          post_authenticated :create:_path, @critic, params: {:user_feedback => {:category => "positive", :user_name => @user.name, :body => "xxx"}}
          assert_not_nil(assigns(:user_feedback))
          assert_equal([], assigns(:user_feedback).errors.full_messages)
        end
      end
    end

    context "update action" do
      should "update the feedback" do
        @feedback = FactoryBot.create(:user_feedback, user: @user, category: "negative")
        put_authenticated :update:_path, @critic, params: { id: @feedback.id, user_feedback: { category: "positive" }}

        assert_redirected_to(@feedback)
        assert("positive", @feedback.reload.category)
      end
    end

    context "destroy action" do
      setup do
        @user_feedback = FactoryBot.create(:user_feedback, user: @user)
      end

      should "delete a feedback" do
        assert_difference "UserFeedback.count", -1 do
          post_authenticated :destroy:_path, @critic, params: {:id => @user_feedback.id}
        end
      end

      context "by a moderator" do
        should "allow deleting feedbacks given to other users" do
          assert_difference "UserFeedback.count", -1 do
            post_authenticated :destroy:_path, @mod, params: {:id => @user_feedback.id}
          end
        end

        should "not allow deleting feedbacks given to themselves" do
          @user_feedback = FactoryBot.create(:user_feedback, user: @mod)
          assert_difference "UserFeedback.count", 0 do
            post_authenticated :destroy:_path, @mod, params: {:id => @user_feedback.id}
          end
        end
      end
    end
  end
end
