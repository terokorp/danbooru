require 'test_helper'

class Admin::DashboardsControllerTest < ActionDispatch::IntegrationTest
  context "The admin dashboard controller" do
    context "show action" do
      should "render" do
        get :show
        assert_response :success
      end
    end
  end
end
