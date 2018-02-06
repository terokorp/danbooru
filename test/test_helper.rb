ENV["RAILS_ENV"] = "test"

if ENV["SIMPLECOV"]
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_group "Libraries", ["app/logical", "lib"]
    add_group "Presenters", "app/presenters"
  end
end

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'cache'
require 'webmock/minitest'

Dir[File.expand_path(File.dirname(__FILE__) + "/factories/*.rb")].each {|file| require file}
Dir[File.expand_path(File.dirname(__FILE__) + "/test_helpers/*.rb")].each {|file| require file}

Dotenv.load(Rails.root + ".env.local")

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.library :rails
  end
end

class ActiveSupport::TestCase
  include PostArchiveTestHelper
  include PoolArchiveTestHelper
  include ReportbooruHelper
  include DownloadTestHelper
  include IqdbTestHelper
  include SavedSearchTestHelper
  include UploadTestHelper

  setup do
    mock_popular_search_service!
    mock_missed_search_service!
    WebMock.allow_net_connect!
    Danbooru.config.stubs(:enable_sock_puppet_validation?).returns(false)
  end

  teardown do
    Cache.clear
  end
end

class ActionDispatch::IntegrationTest
  def method_authenticated(method, url, user, options)
    api_key = ApiKey.generate!(user) unless user.api_key.present?
    self.send(method, url, options.merge(headers: {"HTTP_AUTHORIZATION" => build_authorization_string(user, api_key)}))
  end

  def build_authorization_string(user, api_key)
    "Basic " + Base64.strict_encode64("#{user.name}:#{api_key.key}")
  end

  def get_authenticated(url, user, options = {})
    method_authenticated(:get, url, user, options)
  end

  def post_authenticated(url, user, options = {})
    method_authenticated(:post, url, user, options)
  end

  def put_authenticated(url, user, options = {})
    method_authenticated(:put, url, user, options)
  end

  def delete_authenticated(url, user, options = {})
    method_authenticated(:delete, url, user, options)
  end

  def setup
    super
    Danbooru.config.stubs(:enable_sock_puppet_validation?).returns(false)
  end

  def teardown
    super
    Cache.clear
  end
end

Delayed::Worker.delay_jobs = false

Rails.application.load_seed
