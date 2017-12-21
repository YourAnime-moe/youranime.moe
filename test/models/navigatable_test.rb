require 'models/tanoshimu_base_test'

class NavigatableTest < TanoshimuBaseTest

    test "New instance has no previous instance" do
        instance = Episode.new
        assert_save instance
        assert_nil instance.previous
    end

    test "New instance has no next instance" do
        instance = Episode.new
        assert_save instance
        assert_nil instance.next
    end

    test "Instance has valid previous instance" do
        previous_instance = Episode.new
        assert_save previous_instance
        
        instance = Episode.new
        assert_save instance

        following_instance = Episode.new
        assert_save following_instance

        assert instance.previous == previous_instance
        assert_not instance.previous == following_instance
    end

    test "Instance has valid next instance" do
        instance = Episode.new
        assert_save instance

        next_instance = Episode.new
        assert_save next_instance

        following_instance = Episode.new
        assert_save following_instance

        assert instance.next == next_instance
        assert_not instance.next == following_instance
    end

    test "First instance is first and last" do
        instance = Episode.new
        assert_save instance
        assert instance.is_first?
        assert instance.is_last?
    end

    test "Valid first and last instances" do
        first_instance = Episode.new
        assert_save first_instance
        second_instance = Episode.new
        assert_save second_instance
        last_instance = Episode.new
        assert_save last_instance

        assert first_instance.is_first?
        assert last_instance.is_last?
        assert_not first_instance.is_last?
        assert_not last_instance.is_first?
        assert_not second_instance.is_first?
        assert_not second_instance.is_last?
    end

    test "Valid plus instance" do
        episode_1 = Episode.new; episode_2 = Episode.new
        assert_save_models [episode_1, episode_2]

        assert episode_1 + 0 == episode_1
        assert episode_1 + 1 == episode_2
    end

    test "Valid plus negative instance" do
        episode_1 = Episode.new; episode_2 = Episode.new
        assert_save_models [episode_1, episode_2]

        assert episode_2 + -1 == episode_1
    end

    test "Valid plus 3 instances" do
        episode_1 = Episode.new; episode_4 = Episode.new
        assert_save_models [episode_1, Episode.new, Episode.new, episode_4]
        
        assert episode_1 + 3 == episode_4
        assert_not episode_1 + 1 == episode_4
        assert_not episode_1 + 2 == episode_4
    end

    test "Valid minus instance" do
        episode_1 = Episode.new; episode_2 = Episode.new
        assert_save_models [episode_1, episode_2]

        assert episode_1 - 0 == episode_1
        assert episode_2 - 1 == episode_1
    end

    test "Valid minus negative instance" do
        episode_1 = Episode.new; episode_2 = Episode.new
        assert_save_models [episode_1, episode_2]

        assert episode_1 - -1 == episode_2
    end

    test "Valid minus 3 instances" do
        episode_1 = Episode.new; episode_4 = Episode.new
        assert_save_models [episode_1, Episode.new, Episode.new, episode_4]
        
        assert episode_4 - 3 == episode_1
        assert_not episode_4 - 1 == episode_1
        assert_not episode_4 - 2 == episode_1
    end

end
