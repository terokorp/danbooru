require 'test_helper'

class ArtistVersionsControllerTest < ActionController::TestCase
  context "An artist versions controller" do
    setup do
      CurrentUser.user = FactoryBot.create(:gold_user)
      CurrentUser.ip_addr = "127.0.0.1"
      @artist = FactoryBot.create(:artist)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "get the index page" do
      session[:user_id] = CurrentUser.id
      get :index
      assert_response :success
    end

    should "get the index page when searching for something" do
      session[:user_id] = CurrentUser.id
      get :index, params: {:search => {:name => @artist.name}}
      assert_response :success
    end
  end
end
