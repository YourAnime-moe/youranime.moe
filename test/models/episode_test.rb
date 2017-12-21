require 'models/tanoshimu_base_test'

class EpisodeTest < TanoshimuBaseTest

    setup do
        @dummy_user = users(:dummy)
        @show = shows(:anime_one_subbed)
        @dubbed_show = shows(:anime_one_dubbed)
    end

    test "Episode number 1 if first" do
        episode = Episode.new
        assert_save episode
        assert episode.number == 1
    end

    test "Episode valid number" do
        assert_save Episode.new
        assert_save Episode.new
        episode = Episode.new
        assert_save episode
        assert episode.number == 3
    end

    test "New episode has no show" do
        episode = Episode.new
        assert_save episode
        assert_nil episode.show
    end

    test "Episode has valid show" do
        episode = Episode.new
        episode.show_id = @show.id
        assert_save episode

        assert episode.show == @show
    end

    test "New episode is not published" do
        episode = Episode.new
        assert_save episode
        assert_not episode.is_published?
    end

    test "Episode cannot have published status without a show" do
        episode = Episode.new
        assert_save episode
        assert_not episode.is_published?
    end 

    test "Episode is published" do
        episode = Episode.new show_id: @show.id
        episode.published = true
        assert_save episode
        assert episode.is_published?
    end

    test "Episode has valid path extension" do
        episode = Episode.new
        episode.path = "/videos/show/ep01.mp4"
        assert_save episode
        assert episode.get_path_extension == "mp4"
        episode.path = "/videos/show/ep01.mkv"
        assert_save episode
        assert episode.get_path_extension == "mkv"
    end

    test "New episode has no previous or next episodes" do
        episode = Episode.new
        assert_save episode
        assert_nil episode.previous
        assert_nil episode.next
    end

    test "Episode has valid previous episode" do
        previous_episode = Episode.new(show_id: @show.id)
        episode = Episode.new(show_id: @show.id)
        assert_save_models [Episode.create(show_id: @show.id), Episode.create(show_id: @show.id)]
        assert_save_models [previous_episode, episode]

        assert episode.has_previous?
        assert episode.previous == previous_episode
    end

    test "Episode has valid next episode" do
        next_episode = Episode.new(show_id: @show.id)
        episode = Episode.new(show_id: @show.id)
        assert_save_models [Episode.create(show_id: @show.id), Episode.create(show_id: @show.id)]
        assert_save_models [episode, next_episode]

        assert episode.has_next?
        assert_equal episode.next, next_episode
    end

    test "Episode has valid path" do
        episode = Episode.new(path: "/valid/path.mp4")
        assert_save episode
        assert_equal episode.get_path, Config.main_host + "/valid/path.mp4"
    end

    test "Episode has valid new path" do
        episode = Episode.new(path: "/videos/show/ep8014.mp4")
        assert_save episode
        assert_equal episode.get_new_path, Config.path("/videos?show=show&episode=8014&format=mp4&video=true")
    end

    test "Episode has valid image path" do
        episode = Episode.new(path: "/ouhlala/show/ep8014.test_ext")
        assert_save episode
        assert_equal episode.get_image_path(ext: "test_ext"), Config.main_host + "/ouhlala/show/ep8014.test_ext"
    end

    test "Episode has valid new image path" do
        episode = Episode.new(path: "/videos/show/ep8014.test_ext")
        assert_save episode
        assert_equal episode.get_new_image_path(ext: "test_ext"), Config.main_host + "/videos?show=show&episode=8014&format=test_ext"

    end

    test "No subs if no path" do
        episode = Episode.new(show_id: @show.id)
        assert_save episode
        assert_raises NoMethodError do
            episode.get_subtitle_path
        end
    end

    test "Only subbed episodes have subs" do
        dubbed_episode = Episode.new(show_id: @dubbed_show.id, path: "/videos/dub_show/ep8014.video")
        subbed_episode = Episode.new(show_id: @show.id, path: "/videos/show/ep8014.video")
        assert_save_models [subbed_episode, dubbed_episode]
        assert_nil dubbed_episode.get_subtitle_path
        assert_not_nil subbed_episode.get_subtitle_path
    end

    test "Episode has valid subs path" do
        episode = Episode.new(show_id: @show.id, path: "/videos/show/ep8014.video")
        assert_save episode
        assert_equal episode.get_subtitle_path, Config.path("/videos/show/ep8014.vtt")
    end

    test "Episode has valid new subs path" do
        episode = Episode.new(show_id: @show.id, path: "/videos/show/ep8014.video")
        assert_save episode
        assert_equal episode.get_new_subtitle_path, Config.path("/videos?show=show&episode=8014&format=vtt&subtitles=true")
    end

    test "Episode was not watched by user" do
        Episode.create;Episode.create;Episode.create;Episode.create;
        episode = Episode.new
        assert_save episode
        episode.was_watched_by? @dummy_user
    end

    test "Episode was watched by user" do
        episode = Episode.new
        assert_save episode
        episode.was_watched_by? @dummy_user
    end

    test "Episode has watched mark" do
        episode = Episode.new
        assert_save episode
        assert episode.has_watched_mark?
    end

    test "Episode comment not accepted if not hash" do
        episode = Episode.new
        assert_save episode
        assert_equal episode.add_comment(1), {success: false, message: "Invalid data was received."}
    end

    test "Episode adds new comment" do
        episode = Episode.new
        assert_save episode
        assert_equal episode.add_comment({}), {success: true, message: "Comment was received."}
    end

    test "Episode gets all comments" do
        episode = Episode.new
        assert_save episode

        comments = [
            {text: "one", time: Utils.get_date_from_time(Time.now), user_id: @dummy_user.id}, 
            {text: "two", time: Utils.get_date_from_time(Time.now), user_id: @dummy_user.id}
        ]
        comments.each do |comment|
            assert_equal episode.add_comment(comment), {success: true, message: "Comment was received."}
        end 
        assert_equal episode.get_comments, episode.comments
    end

    test "Episode has instances" do
        assert Episode.instances.size > 0
    end

end
