require 'models/tanoshimu_base_test'

class ShowTest < TanoshimuBaseTest

    setup do
        @show_one_subbed = shows(:anime_one_subbed)
        @show_two_subbed = shows(:anime_two_subbed)
        @show_unpublished = shows(:unpublished)
    end

    test "New show should be subbed by default" do
        show = Show.new
        assert_save show
        assert show.subbed
    end

    test "New show should not be dubbed by default" do
        show = Show.new
        assert_save show
        assert_not show.dubbed
    end

    test "Subbed shows should have subs" do
        show = Show.new
        show.subbed = true
        show.title = "My subbed show"
        assert_save show

        assert show.subbed

        (1..10).each do |e|
            episode = Show::Episode.new
            episode.show_id = show.id
            assert episode.has_subs?
        end
    end

    test "Dubbed shows should not have subs" do
        show = Show.new
        show.dubbed = true
        show.title = "My dubbed show"
        assert_save show

        assert show.dubbed

        (1..10).each do |e|
            episode = Show::Episode.new
            episode.show_id = show.id
            assert_not episode.has_subs?
        end
    end

    test "Show is dubbed" do
        show = Show.new
        show.dubbed = true
        assert_save show
        assert show.dub_sub_info == "Dubbed"
        assert_not show.dub_sub_info == "Subbed"
        assert_not show.dub_sub_info == "Dubbed and Subbed"
    end

    test "Show is subbed" do
        show = Show.new
        assert_save show
        assert_not show.dub_sub_info == "Dubbed"
        assert show.dub_sub_info == "Subbed"
        assert_not show.dub_sub_info == "Dubbed and Subbed"
    end

    test "Show is dubbed and subbed" do
        show = Show.new
        show.dubbed = true
        show.subbed = true
        assert_save show
        assert_not show.dub_sub_info == "Dubbed"
        assert_not show.dub_sub_info == "Subbed"
        assert show.dub_sub_info == "Dubbed and Subbed"
    end

    test "Show has correct title" do
        show = Show.new
        show.title = "Mytitle"
        assert_save show
        assert show.get_title == "Mytitle"
    end

    test "Show has correct alternate title" do
        show = Show.new
        show.title = "Mytitle"
        show.alternate_title = "MY TITLE"
        assert_save show
        assert show.get_title == "MY TITLE"
    end

    test "Show has valid prequel" do
        show = Show.new
        show.title = "Myshow"
        show.alternate_title = "Actual Show"
        show.show_number = 2
        assert_save show

        prequel = Show.new
        prequel.title = "Myshow"
        prequel.alternate_title = "Prequel"
        prequel.show_number = 1
        assert_save prequel

        assert prequel == show.prequel
    end

    test "Show has valid sequel" do
        show = Show.new
        show.title = "Myshow"
        show.alternate_title = "Actual Show"
        show.show_number = 1
        assert_save show

        sequel = Show.new
        sequel.title = "Myshow"
        sequel.alternate_title = "Sequel"
        sequel.show_number = 2
        assert_save sequel

        assert sequel == show.sequel
    end

    test "Only show has not prequel/sequel" do
        show = Show.new
        assert_save show
        assert_nil show.prequel
        assert_nil show.sequel
    end

    test "Show has ten episodes" do
        show = Show.new
        show.published = true
        assert_save show
        (1..10).each do |episode_number|
            episode = Show::Episode.new
            episode.show_id = show.id
            episode.published = true
            assert_save episode
        end
        assert show.episodes.size == 10
    end

    test "Show has no episodes when not published" do
        show = Show.new
        assert_save show
        (1..10).each do |episode_number|
            episode = Show::Episode.new
            episode.show_id = show.id
            episode.published = true
            assert_save episode
        end
        assert show.episodes.size == 0
    end

    test "Show has 5 episodes (out of 10 new episodes)" do
        show = Show.new
        assert_save show
        count = 5
        (1..10).each do |episode_number|
            episode = Show::Episode.new
            episode.title = "Episode #{episode_number}"
            episode.episode_number = episode_number
            episode.show_id = show.id
            if count >= 0
                episode.published = true
                count -= 1
            end
            assert_save episode
        end
        assert show.episodes.size == 0
    end

    test "Show has 200 episodes" do
        show = Show.new
        assert_save show
        count = 200
        (1..count).each do |episode_number|
            episode = Show::Episode.new
            episode.show_id = show.id
            assert_save episode
        end
        assert show.all_episodes.size == count
    end

    test "Show gets episodes after episode 150 as integer" do
        show = Show.new(published: true)
        assert_save show
        count = 200
        (1..count).each do |episode_number|
            episode = Show::Episode.new(published: true, show_id: show.id, episode_number: episode_number)
            assert_save episode
        end
        show.episodes(from: 150).each do |episode|
            assert episode.episode_number >= 150
        end
    end

    test "Show gets episodes after episode 150" do
        show = Show.new(published: true)
        assert_save show
        count = 200
        episode_from = nil
        (1..count).each do |episode_number|
            episode = Show::Episode.new(published: true, show_id: show.id, episode_number: episode_number)
            episode_from = episode if episode_number == 150
            assert_save episode
        end
        show.episodes(from: episode_from).each do |episode|
            assert episode.episode_number >= 150
        end
    end

    test "Show splits properly episodes" do
        show = Show.new(published: true)
        assert_save show
        count = 200
        (1..count).each do
            episode = Show::Episode.new(show_id: show.id, published: true)
            assert_save episode
        end
        assert_equal show.split_episodes(sort_by: 4).size, 50 # 200/4 = 50
        assert_equal show.split_episodes(sort_by: 3).size, 67 # 200/3 = 66.6 ==> 67
    end

    test "Show has empty tags" do
        show = Show.new
        assert_save show
        assert_nil show.tags
        assert_not show.get_tags.nil?
    end

    test "Show has two tags" do
        show = Show.new
        assert_save show
        assert_not show.add_tag(:romance).nil?
        assert_not show.add_tag(:action).nil?
        assert_save show
        assert show.get_tags.size == 2
    end

    test "Show has two tags (out of 5)" do
        show = Show.new
        assert_save show
        assert_not show.add_tag(:romance).nil?
        assert_not show.add_tag(:action).nil?
        assert_not show.add_tag(:fake_1)
        assert_not show.add_tag(:fake_2)
        assert_not show.add_tag(:fake_3)
        assert_save show
        assert_equal show.get_tags.size, 2
        assert show.has_tags?
        assert show.has_tags? [:romance, :action]
        assert show.has_tags? [:action, :romance]
        assert_not show.has_tags? [:fake_1]
        assert_not show.has_tags? [:fake_2]
        assert_not show.has_tags? [:fake_3]
    end

    test "Show test has tags" do
        show = Show.new
        assert_not show.add_tag(:romance).nil?
        assert_not show.add_tag(:action).nil?
        assert_save show
        assert show.has_tags? [:action, :romance]
        assert show.has_tags?
        assert show.has_tags? nil
        assert_not show.has_tags? 1
        assert_not show.has_tags? ""
        assert_not show.has_tags? []
    end

    test "Show check has starring info" do
        show = Show.new
        show.starring = "thedrummeraki"
        assert_save show
        assert show.has_starring_info?
        assert show.starring == "thedrummeraki"
    end

    test "Show check has average run time" do
        show = Show.new
        show.average_run_time = 20
        assert show.discloses_average_run_time?
        assert show.average_run_time == 20
    end

    test "Show check is published" do
        show = Show.new
        assert_save show
        assert_not show.is_published?
    end

    test "Show check is not published by default" do
        show = Show.new
        show.published = true
        assert_save show
        assert show.is_published?
    end

    test "Show check has episodes" do
        show = Show.new
        show.published = true
        assert_save show
        (1..5).each do |episode_number|
            episode = Show::Episode.new
            episode.show_id = show.id
            episode.published = true
            assert_save episode
        end
        assert show.has_episodes?
    end

    test "Show check has tags" do
        show = Show.new
        assert_save show
        assert_not show.add_tag(:romance).nil?
        assert_not show.add_tag(:action).nil?
        assert_save show
        assert show.has_tags?
    end

    test "Show get image path" do
        show = Show.new
        assert_save show
        assert_nil show.get_image_path
        show.image_path = "/video/icons/show.png"
        assert_save show
        assert show.get_image_path == "#{Config.main_host}/video/icons/show.png"
    end

    test "Show get new image path" do
        show = Show.new
        assert_save show
        assert_nil show.get_new_image_path
        show.image_path = "/video/blablabla/show.png"
        assert_save show
        assert show.get_new_image_path == "#{Config.main_host}/videos?show_icon=show&format=png&under=blablabla"
    end

    test "Show check has image" do
        show = Show.new
        show.image_path = "/some/path/you/are.jpg"
        assert_save show
        assert show.has_image?
    end

    test "Show check has description" do
        show = Show.new
        show.description = "This is my nice description"
        assert_save show
        assert show.has_description?
    end

    test "Show check if is featured" do
        show = Show.new
        show.featured = true
        assert_save show
        assert show.is_featured?
    end

    test "Show check if is recommended" do
        show = Show.new
        show.recommended = true
        assert_save show
        assert show.is_recommended?
    end

    test "Show check if anime without type" do
        show = Show.new
        assert_save show
        assert show.is_anime?
    end

    test "Show check if anime" do
        show = Show.new
        show.show_type = 0
        assert_save show
        assert show.is_anime?
    end

    test "Show check if movie" do
        show = Show.new
        show.show_type = 2
        assert_save show
        assert show.is_movie?
    end

    test "Show check if drama" do
        show = Show.new
        show.show_type = 1
        assert_save show
        assert show.is_drama?
    end

    test "Show check only anime not movie nor drama" do
        show = Show.new
        show.show_type = 0
        assert_save show
        assert show.is_anime?
        assert_not show.is_movie?
        assert_not show.is_drama?
    end

    test "New show check get year" do
        show = Show.new
        assert show.get_year == 0.years.ago.year
    end

    test "Show check get year" do
        show = Show.new
        show.year = 566
        assert_save show
        assert show.get_year == 566
    end

    test "Show check get season code" do
        show = Show.new
        show.season_code = 2
        assert_save show
        assert show.get_season_code == 2
    end

    test "Show check get empty season year" do
        show = Show.new
        show.year = 566
        assert_save show
        assert show.get_season_year == 566
    end

    test "Show check get season year" do
        show = Show.new
        show.season_year = 567
        assert_save show
        assert show.get_season_year == 567
    end

    test "Show check if this season" do
        show = Show.new
        show.season_code = Utils.current_season
        show.season_year = Time.now.year
        assert_save show
        assert show.is_this_season?
    end

    test "Show check if not this season" do
        season_code = -1
        loop do
            season_code += 1
            break if season_code == Utils.current_season
        end
        show = Show.new
        show.season_code = season_code
        assert_save show
        assert_not show.is_this_season?
    end

    test "Show get description with limit 10" do
        limit = 10
        show = Show.new
        show.description = "LongText"*100
        assert_save show
        assert show.get_description(limit).size == limit+3
    end

    test "Show get description without limit" do
        show = Show.new
        show.description = "LongText"*100
        assert_save show
        assert show.get_description(nil).size == show.description.size
    end

    test "Show get description with larger limit" do
        show = Show.new
        show.description = "LongText"
        assert_save show
        assert_equal show.get_description(100).size, show.description.size + 3
    end

    test "Show doesn't allow negative show numbers" do
        show = Show.new
        show.show_number = -1
        assert_not_save show
        assert show.errors.to_a.include? "Show number can't be negative"
    end

    test "Show utils self get" do
        assert_nil Show.get title: "thedrummeraki"
        assert_not_nil Show.get title: "thedrummeraki", show_number: 1
        assert_not_nil Show.get title: "thedrummeraki", show_number: 2
        assert_not_nil Show.get title: "Thedrummeraki", show_number: 1
        assert_not_nil Show.get title: "Thedrummeraki", show_number: 2
        assert_equal Show.get(title: "thedrummeraki", show_number: 1), @show_one_subbed
    end

    test "Show utils self instances" do
        assert_equal Show.instances, [:get_title]
    end

    test "Show utils self get presence" do
        assert_equal Show.get_presence(:recommended).size, 2
        assert_equal Show.get_presence(:featured).size, 1
        assert_not_nil Show.get_presence(:season, 100, options: {})
        assert_raises RuntimeError do
            Show.get_presence :season, 100
        end
    end

    test "Show utils self latest" do
        user = users(:five_episodes_watched)
        assert_save Show::Episode.new(episode_number: 1, show_id: @show_one_subbed.id, published: true)
        assert_save Show::Episode.new(episode_number: 2, show_id: @show_one_subbed.id, published: true)
        assert_save Show::Episode.new(episode_number: 1, show_id: @show_two_subbed.id, published: true)
        assert_save Show::Episode.new(episode_number: 1, show_id: @show_unpublished.id, published: true)
        assert_save Show::Episode.new(episode_number: 2, show_id: @show_two_subbed.id)

        latest_shows = Show.lastest(user)

        assert_equal latest_shows.size, 2
        assert latest_shows.include? @show_one_subbed
        assert latest_shows.include? @show_two_subbed
    end

    test "All shows are published" do
        count = 10
        (1..count).each do |i|
            assert_save Show.new(published: true, title: "show##{i}")
        end
        all_episodes = Show.all_published
        assert_equal all_episodes.size, count + 3
        i = 0
        Show.all.select{|e| e.is_published?}.each do |episode|
            all_episodes.include? episode
            i += 1
        end
        assert_equal i, count + 3
    end

end
