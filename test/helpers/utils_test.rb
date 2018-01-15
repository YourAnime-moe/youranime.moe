require 'helpers/utils_base_test'

class UtilsTest < UtilsBaseTest

    setup do
        @path = "/tmp/fake/fake/file.test"
    end

    test "Utils test has tags" do
        assert_not_nil Utils.tags
    end

    test "Utils get tag name valid" do
        assert_equal Utils.get_tag_name(:vampire), "Vampire"
        assert_equal Utils.get_tag_name(:ecchi), "Ecchi/Fan Service"
        assert_equal Utils.get_tag_name(:action), "Action"
        assert_equal Utils.get_tag_name(:slice), "Slice of Life"
        assert_equal Utils.get_tag_name(:romance), "Romance"
        assert_nil Utils.get_tag_name(:fake_tag)
    end

    test "Utils get parent directory" do
        assert_nil Utils.get_parent_directory nil
        assert_equal Utils.get_parent_directory("/home/test/dir"), "/home/test"
    end

    test "Utils create and delete file" do
        contents = "hello this is a test"
        assert Utils.create_file @path, contents
        File.open(@path) do |io|
            assert_equal io.read, contents
        end
        assert_equal Utils.delete_files([@path]), 1
        assert Utils.create_file @path, contents
        File.open(@path) do |io|
            assert_equal io.read, contents
        end
        assert_equal Utils.delete_file(@path), [@path]
        forbidden_path = "/iamjustafileonroot"
        assert_not Utils.create_file forbidden_path, contents
    end

    test "Utils check valid email" do
        assert_nil Utils.check_valid_email nil
        assert Utils.check_valid_email "test@test.org"
        assert Utils.check_valid_email "test.email@test.org"
        assert Utils.check_valid_email "test-email.29@test.org"
        assert Utils.check_valid_email "test-email29@test.org"
        assert Utils.check_valid_email "test-email29@test.org.com.haha.infine.fake.com"
        assert_not Utils.check_valid_email "test-email29@test@org.com.haha.infine.fake.com"
        assert_not Utils.check_valid_email "test-email29@test@org.com.haha.infine.fake com"
    end

    test "Utils random" do
        assert_equal Utils.random(1000).length, 1000
        assert_equal Utils.hex_random(1000).length, 1000
        assert_equal Utils.color_random.length, 6 + 1
        assert Utils.color_random.start_with? "#{}"

        choose_between = Utils.choose_between(1, 20)
        assert choose_between >= 1 && choose_between <= 20
        assert_not choose_between < 1 || choose_between > 20
    end

    test "Utils today" do
        assert_not_nil Utils.today
        assert_not_nil Utils.today(hour_of_day=false)
    end

    test "Utils search" do
        shows_list = [
            shows(:anime_one_subbed),
            shows(:anime_two_subbed),
            shows(:unpublished)
        ]
        assert_equal Utils.search(nil, shows_list), shows_list
        assert_equal Utils.search("", shows_list), shows_list
        assert_equal Utils.search("", shows_list, nil), shows_list
        assert_equal Utils.search("", shows_list, []), shows_list

        assert_equal Utils.search("drumm", shows_list).size, 2
        assert_equal Utils.search("season 2", shows_list).size, 1
        assert_equal Utils.search("show that doesn't exist", shows_list).size, 0
        assert_equal Utils.search("drumm", shows_list, [:title]).size, 1
        assert_equal Utils.search("season 2", shows_list, [:title]).size, 0
        assert_equal Utils.search("Thedrummeraki", shows_list, [:title]).size, 1
    end

    #test "Utils split array" do
    #    assert_equal Utils.split_array(Show, sort_by: 1).size, 3
    #end

    test "Utils add to list" do
        array = []
        Utils.add_to_list array, "1"
        Utils.add_to_list array, "2"
        assert_equal array.size, 2
        Utils.add_to_list array, "2"
        assert_equal array.size, 2
        Utils.add_to_list array, "2", doubles: true
        assert_equal array.size, 3
    end

    test "Utils pretty number" do
        assert_equal Utils.pretty_number(nil), ""
        assert_equal Utils.pretty_number(0), "00"
        assert_equal Utils.pretty_number(1), "01"
        assert_equal Utils.pretty_number(100), "100"
        assert_equal Utils.pretty_number(7), "07"
        assert_equal Utils.pretty_number(-7), "-07"
        assert_equal Utils.pretty_number(-100), "-100"
    end

    test "Utils ordinal number" do
        assert_equal Utils.get_ordinal_number(nil), "0th"
        assert_equal Utils.get_ordinal_number(0), "0th"
        assert_equal Utils.get_ordinal_number(1), "01st"
        assert_equal Utils.get_ordinal_number(2), "02nd"
        assert_equal Utils.get_ordinal_number(3), "03rd"
        assert_equal Utils.get_ordinal_number(4), "04th"
        assert_equal Utils.get_ordinal_number(7), "07th"
        assert_equal Utils.get_ordinal_number(17), "17th"
        assert_equal Utils.get_ordinal_number(-33), "-33rd"
        assert_equal Utils.get_ordinal_number(1, pretty_number: false), "1st"
    end

    test "Utils date from" do
        assert_equal Utils.date_from, "N/A"
        assert_not_nil Utils.date_from(Show.all[0])
        assert_not_nil Utils.date_from(Show.all[0], false)
    end

    test "Utils get date from time" do
        assert_not_nil Utils.get_date_from_time Time.now
    end

    test "Utils full model date from " do
        assert_equal Utils.full_model_date_from, "N/A"
        assert_not_nil Utils.full_model_date_from(Show.all[0])
        assert_not_nil Utils.full_model_date_from(Show.all[0], false)
    end

    test "Utils full date from" do
        assert_equal Utils.full_date_from(9320, 392, 382, 21), "N/A"
        assert_equal Utils.full_date_from(2017, 1, 1), "January 01st, 2017 - 00:00:00"
        assert_equal Utils.full_date_from(2017, 2, 1), "February 01st, 2017 - 00:00:00"
        assert_equal Utils.full_date_from(2017, 3, 1), "March 01st, 2017 - 00:00:00"
        assert_equal Utils.full_date_from(2017, 4, 1), "April 01st, 2017 - 00:00:00"
        assert_equal Utils.full_date_from(2017, 5, 1), "May 01st, 2017 - 00:00:00"
        assert_equal Utils.full_date_from(2017, 6, 1), "June 01st, 2017 - 00:00:00"
        assert_equal Utils.full_date_from(2017, 8, 1), "August 01st, 2017 - 00:00:00"
        assert_equal Utils.full_date_from(2017, 9, 1), "September 01st, 2017 - 00:00:00"
        assert_equal Utils.full_date_from(2017, 10, 1), "October 01st, 2017 - 00:00:00"
        assert_equal Utils.full_date_from(2017, 11, 1), "November 01st, 2017 - 00:00:00"
        assert_equal Utils.full_date_from(2017, 12, 1), "December 01st, 2017 - 00:00:00"
        assert_equal Utils.full_date_from(2017, 7, 22, 23, 56, 24), "July 22nd, 2017 - 23:56:24"
    end

    test "Utils is valid date" do
        assert_not Utils.is_valid_date 9320, 392, 382
        assert Utils.is_valid_date 2017, 1, 1
        assert Utils.is_valid_date 2017, 7, 22
        assert_not Utils.is_valid_date 2, 12, 31
        assert_not Utils.is_valid_date 1197, 11, 30
        assert Utils.is_valid_date 2928, 9, 2
    end

    test "Utils today's date" do
        assert_equal Utils.get_todays_date.size, 3
    end

    test "Utils get years range" do
        assert_not_nil Utils.get_years_range
    end

    test "Utils get months range" do
        assert_not_nil Utils.get_months_range
    end

    test "Utils get days range" do
        assert_not_nil Utils.get_days_range
    end

    test "Utils get hours range" do
        assert_not_nil Utils.get_hours_range
    end

    test "Utils get seconds and mins range" do
        assert_not_nil Utils.get_minutes_and_seconds_range
    end

    test "Utils show currency" do
        assert_equal Utils.show_currency(nil), "N/A"
        assert_equal Utils.show_currency(23.43), "23.43$"
        assert_equal Utils.show_currency(23.435), "23.44$"
        assert_equal Utils.show_currency(0.00001), "0.00$"
        assert_equal Utils.show_currency(10), "10.00$"
    end

    test "Utils get class from string" do
        assert_nil Utils.get_class_from_string(nil)
        assert_equal Utils.get_class_from_string("ActiveRecord::Base"), ActiveRecord::Base
        assert_raises NameError do
            Utils.get_class_from_string("ActiveRecords::Base")
        end
    end

    test "Utils get today's day index" do
        assert_not_nil Utils.get_todays_day_index
    end

    test "Utils current season" do
        assert_equal Utils.current_season(Time.new(2018, 1, 21)), 0
        assert_equal Utils.current_season(Time.new(2015, 5, 31)), 1
        assert_equal Utils.current_season(Time.new(2016, 7, 3)), 2
        assert_equal Utils.current_season(Time.new(2017, 11, 19)), 3
    end

    test "Utils current season string" do
        assert_equal Utils.current_season_string(Time.new(2018, 1, 21)), "Winter 2018"
        assert_equal Utils.current_season_string(Time.new(2015, 4, 30)), "Spring 2015"
        assert_equal Utils.current_season_string(Time.new(2016, 7, 3)), "Summer 2016"
        assert_equal Utils.current_season_string(Time.new(2017, 11, 19)), "Fall 2017"
    end

end
