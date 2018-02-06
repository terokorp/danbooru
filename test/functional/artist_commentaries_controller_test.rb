require 'test_helper'

class ArtistCommentariesControllerTest < ActionDispatch::IntegrationTest
  context "The artist commentaries controller" do
    setup do
      @user = FactoryBot.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"

      @commentary1 = FactoryBot.create(:artist_commentary)
      @commentary2 = FactoryBot.create(:artist_commentary)
    end

    teardown do
      CurrentUser.user = nil
    end

    context "index action" do
      should "render" do
        get artist_commentaries_path
        assert_response :success
      end

      should "render with search params" do
        params = {
          search: {
            text_matches: @commentary1.original_title,
            post_id: @commentary1.post_id, 
            original_present: "yes",
            translated_present: "yes",
            post_tags_match: @commentary1.post.tag_array.first,
          }
        }

        get artist_commentaries_path(params)
        assert_response :success
      end
    end

    context "show action" do
      should "render" do
        get artist_commentary_path(@commentary1.id)
        assert_redirected_to(@commentary1.post)

        get artist_commentary_path(post_id: @commentary1.post_id)
        assert_redirected_to(@commentary1.post)
      end
    end

    context "create_or_update action" do
      should "render for create" do
        params = {
          artist_commentary: {
            original_title: "foo",
            post_id: FactoryBot.create(:post).id,
          },
          format: "js"
        }

        assert_difference("ArtistCommentary.count", 1) do
          put_authenticated create_or_update_artist_commentaries_path(params), @user, as: :js
        end
        assert_response :success
      end

      should "render for update" do
        params = {
          artist_commentary: {
            post_id: @commentary1.post_id,
            original_title: "foo",
          },
          format: "js"
        }

        put_authenticated create_or_update_artist_commentaries_path(params), @user
        @commentary1.reload
        assert_response :success
        assert_equal("foo", @commentary1.reload.original_title)
      end
    end

    context "revert action" do
      should "work" do
        original_title = @commentary1.original_title
        @commentary1.update(original_title: "foo")
        @commentary1.reload
        put_authenticated revert_artist_commentary_path(@commentary1.post_id, version_id: @commentary1.versions.first.id, format: "js"), @user
        assert_response :success
        assert_equal(original_title, @commentary1.reload.original_title)
      end

      should "return 404 when trying to revert a nonexistent commentary" do
        put_authenticated revert_artist_commentary_path(-1, version_id: -1, format: "js"), @user
        assert_response 404
      end

      should "not allow reverting to a previous version of another artist commentary" do
        put_authenticated revert_artist_commentary_path(@commentary1.post_id, version_id: @commentary2.versions.first.id, format: "js"), @user
        @commentary1.reload
        assert_not_equal(@commentary1.original_title, @commentary2.original_title)
        assert_response :missing
      end
    end
  end
end
