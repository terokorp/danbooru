require 'test_helper'

class ArtistVersionsControllerTest < ActionDispatch::IntegrationTest
  context "An artist versions controller" do
    setup do
      @user = FactoryBot.create(:gold_user)
      @artist = FactoryBot.build(:artist, creator: @user)
      @artist.save
    end

    should "get the index page" do
      get_authenticated artist_versions_path, @user
      assert_response :success
    end

    should "get the index page when searching for something" do
      get_authenticated artist_versions_path(search: {name: @artist.name}), @user
      assert_response :success
    end
  end
end
