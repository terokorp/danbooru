require 'test_helper'

class UserNameChangeRequestsControllerTest < ActionDispatch::IntegrationTest
  context "The user name change requests controller" do
    setup do
      @user = FactoryBot.create(:gold_user)
      @admin = FactoryBot.create(:admin_user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @change_request = UserNameChangeRequest.create!(
        :user_id => @user.id,
        :original_name => @user.name,
        :desired_name => "abc",
        :change_reason => "hello"
      )
    end
    
    context "new action" do
      should "render" do
        get :new, {}, {:user_id => @user.id}
        assert_response :success
      end
    end

    context "create action" do
      should "work" do
        post_authenticated :create:_path, @user, params: { user_name_change_request: { desired_name: "zun" }}
        assert_response :success
      end
    end
    
    context "show action" do
      should "render" do
        get_authenticated :show:_path, @user, params: {:id => @change_request.id}
        assert_response :success
      end

      context "when the current user is not an admin and does not own the request" do
        setup do
          CurrentUser.user = FactoryBot.create(:user)
        end

        should "fail" do
          get :show, {:id => @change_request.id}
          assert_redirected_to(new_session_path(:url => user_name_change_request_path(@change_request)))
        end
      end
    end
    
    context "for actions restricted to admins" do
      context "index action" do
        should "render" do
          get :index, {}, {:user_id => @admin.id}
          assert_response :success
        end
      end
      
      context "approve action" do
        should "succeed" do
          post_authenticated :approve:_path, @admin, params: {:id => @change_request.id}
          assert_redirected_to(user_name_change_request_path(@change_request))
        end
      end
      
      context "reject action" do
        should "succeed" do
          post_authenticated :reject:_path, @admin, params: {:id => @change_request.id}
          assert_redirected_to(user_name_change_request_path(@change_request))
        end
      end
    end
  end
end
