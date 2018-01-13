require 'helpers/utils_base_test'

class ConfigTest < UtilsBaseTest

    setup do
        @path = "config/test.json"
    end

    test "Config admin path valid" do
        assert_equal Config.admin_host(@path), "http://localhost:3128"
        assert_equal Config.admin_host(@path, "key"), "http://localhost:3128"
        assert_equal Config.admin_host(@path, "key", "value"), "http://localhost:3128?key=value"
        assert_equal Config.admin_host(@path, "key", "value", "other"), "http://localhost:3128?key=value"
        assert_equal Config.admin_host(@path, "key", "value", "other", "haha"), "http://localhost:3128?key=value&other=haha"
    end

    test "Config get api info valid" do
        assert_equal Config.api(@path)["host"], "https://api-host.test/endpoint/api"
    end

    test "Config get api env valid" do
        assert_equal Config.env("client_id", nil, @path), "TANOSHIMU_CLIENT_ID"
        assert_equal Config.env("secret_id", nil, @path), "TANOSHIMU_CLIENT_SECRET"
        assert_equal Config.env("fake_key", "DEF_ENV", @path), "DEF_ENV"
    end

end
