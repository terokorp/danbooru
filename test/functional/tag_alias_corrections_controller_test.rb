require 'test_helper'

class TagAliasCorrectionsControllerTest < ActionDispatch::IntegrationTest
  context "The tag alias correction controller" do
    setup do
      @admin = FactoryBot.create(:admin_user)
      CurrentUser.user = @admin
      CurrentUser.ip_addr = "127.0.0.1"
      @tag_alias = FactoryBot.create(:tag_alias, :antecedent_name => "aaa", :consequent_name => "bbb")
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "show action" do
      should "render" do
        get_authenticated :show:_path, @admin, params: {:tag_alias_id => @tag_alias.id}
        assert_response :success
      end
    end

    context "create action" do
      should "render" do
        post_authenticated :create:_path, @admin, params: {:tag_alias_id => @tag_alias.id, :commit => "Fix"}
        assert_redirected_to(tag_alias_correction_path(:tag_alias_id => @tag_alias.id))
      end
    end
  end
end
