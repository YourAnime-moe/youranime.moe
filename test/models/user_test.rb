require 'models/tanoshimu_base_test'

class UserTest < TanoshimuBaseTest

    setup do
        @admin_user = users(:admin)
        @user = users(:test)
        @scared_user = users(:scared_user)
        @scared_user.password = "user"
        @user.password = "test_password"
        @episode = Episode.create
    end

    test "User properly saved" do
        u = User.new(password: "dummy", password_confirmation: "dummy", username: "test-user-1")
        assert_save u
        assert_equal u.get_episodes_watched, []
    end

    test "User not saved if no username" do
        assert_not_save User.new(password: "dummy", password_confirmation: "dummy")
        assert_not_save User.new(password: "dummy", password_confirmation: "dummy", username: "")
        assert_not_save User.new(password: "dummy", password_confirmation: "dummy", username: "   ")
    end

    test "User not saved if existing username" do
        u = User.new(password: "dummy", password_confirmation: "dummy", username: "test-user-1")
        u.username = @user.username
        assert_not_save u
    end

    test "User get name is valid" do
        u = User.new(password: "dummy", password_confirmation: "dummy", username: "test-user-1")
        assert_save u
        assert_equal u.get_name, "test-user-1"
        u.name = "This is another test"
        assert_save u
        assert_equal u.get_name, "This is another test"
    end

    test "User add episode returns false if episode is not int or Episode" do
        assert_not @user.add_episode ""
        assert_not @user.add_episode []
        assert_not @user.add_episode nil
    end

    test "User add episode fails due to settings" do
        assert @user.update_settings({episode_tracking: false})
        assert_not @user.add_episode Episode.create
    end

    test "User add episode returns false if episode does not exist" do
        assert_not @user.add_episode 0
        assert_not @user.add_episode 1000
    end

    test "User add episode already exists valid" do
        # TODO fix here
        episode = Episode.create
        assert @user.add_episode episode.id
    end

    test "User add episode valid" do
        assert @user.add_episode @episode
    end

    test "User get latest episodes valid" do
        assert_equal @user.get_episodes_watched(as_is: true), [1, 2, 3]
        assert_equal @user.get_episodes_watched, [1]
        episode = Episode.create
        assert @user.add_episode episode
        assert_equal @user.get_episodes_watched, [1, 2]
        Episode.find(1).update_attributes published: true
        Episode.find(2).update_attributes published: true
        assert_equal @user.get_latest_episodes.size, 2
        assert_equal @user.get_latest_episodes(limit: 1).size, 1
    end

    test "User has watched anything valid" do
        assert @user.has_watched_anything?
    end

    test "New user has not watched anything valid" do
        assert_not User.new.has_watched_anything?
    end

    test "User has watched nil if episode does not exist" do
        assert_nil @user.has_watched? 0
    end

    test "User has watched episode is valid" do
        assert @user.has_watched? 1
    end

    test "User get valid episode count string" do
        assert_equal @user.get_episode_count, "You have watched one episode."
        assert @user.add_episode Episode.create
        assert_equal @user.get_episode_count, "You have watched 2 episodes."
        assert_equal User.create.get_episode_count, "You have watched 0 episodes."
    end

    test "User no settings allows any settings" do
        assert @user.allows_setting :watch_anime
        assert @user.allows_setting :last_episode
        assert @user.allows_setting :episode_tracking
        assert @user.allows_setting :recommendations
        assert @user.allows_setting :images
    end

    test "User allows setting valid configuration" do
        assert @scared_user.allows_setting :last_episode
        assert_not @scared_user.allows_setting :episode_tracking
    end

    test "User is new valid" do
        assert User.new.is_new?
        assert_not @user.is_new?
    end

    test "User is admin valid" do
        assert @admin_user.is_admin?
        assert_not @user.is_admin?
    end

    test "User is activated by default" do
        user = User.new(password: "user", password_confirmation: "user", username: "user")
        assert_save user
        assert user.is_activated?
    end

    test "User is activated valid" do
        user = User.new(password: "user", password_confirmation: "user", username: "user", is_activated: true)
        assert_save user
        assert user.is_activated?
    end

    test "User is not activated valid" do
        user = User.new(password: "user", password_confirmation: "user", username: "user", is_activated: false)
        assert_save user
        assert_not user.is_activated?
    end

    test "User is demo account valid" do
        user = User.new(password: "user", password_confirmation: "user", username: "demo")
        assert_save user
        assert user.activate
        assert user.is_demo?
    end

    test "User activates properly" do
        user = User.new(password: "user", password_confirmation: "user", username: "user", is_activated: false)
        assert_save user
        assert_not user.is_activated?
        assert user.activate
        assert user.is_activated?
    end

    test "User deactivates properly" do
        user = User.new(password: "user", password_confirmation: "user", username: "user")
        assert_save user
        assert user.deactivate
        assert_not user.is_activated?
    end

    test "User updates settings properly" do
        @user.update_settings({watch_anime: false})
        assert_not @user.allows_setting :watch_anime
    end

    test "User updates settings properly with no default settings" do
        assert_not @scared_user.allows_setting :episode_tracking
        assert @scared_user.update_settings nil
        assert @scared_user.allows_setting :episode_tracking
    end

    test "User token properly destroyed" do
        user = User.new(username: "apiuser", password: "api", password_confirmation: "api")
        assert_save user
        assert user.destroy_token
        assert_nil user.auth_token
        assert user.regenerate_auth_token
        assert_not_nil user.auth_token
        assert user.destroy_token
        assert_nil user.auth_token
    end

    test "User has types" do
        assert_not_nil User.types
    end

end
