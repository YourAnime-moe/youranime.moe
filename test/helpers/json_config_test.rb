require 'helpers/utils_base_test'

class JsonConfigTest < UtilsBaseTest

    setup do
        @json_path = "test/test.json"
        File.open(@json_path, "w") { |io| 
            io.write({
                a: 1,
                b: 2,
                c: ["one", "two", "three"],
                d: {
                    array: ["four", "five"],
                    string: "string",
                    int: 1,
                    bool: true
                },
                e: [
                    {host: "0.0.0.0", subnet: "24", tag: "home"},
                    {host: "0.0.0.1", subnet: "25", tag: "work"},
                    {host: "0.0.1.1", subnet: "26", tag: "school"}
                ]
            }.to_json)
        }
    end

    teardown do
        File.delete @json_path
    end

    test "JSON Config get valid entry" do
        json_contents = JSONConfig.get @json_path
        assert_equal json_contents["a"], 1
        assert_equal json_contents["b"], 2
        assert_equal json_contents["c"].size, 3
        assert_equal json_contents["d"]["array"], ["four", "five"]
        assert_equal json_contents["d"]["string"], "string"
        assert_equal json_contents["d"]["int"], 1
        assert_equal json_contents["d"]["bool"], true
        assert_equal json_contents["e"][0]["host"], "0.0.0.0"
        assert_equal json_contents["e"][1]["subnet"], "25"
        assert_equal json_contents["e"][2]["tag"], "school"
    end

    test "JSON Config throws Exception if file does not exist" do
        assert_raises(Exception) do 
            JSONConfig.get "/fake/path/that/does/not/exist"
        end
    end

end
