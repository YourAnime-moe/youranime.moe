require 'test_helper'

class ShowsControllerTest < ActionDispatch::IntegrationTest
    test "New show should be subbed by default" do
        show = Show.new
        show.save
        assert show.subbed
    end

    test "New show should not be dubbed by default" do
        show = Show.new
        show.save
        assert_not show.dubbed
    end

    test "Subbed shows should have subs" do
        show = Show.new
        show.subbed = true
        show.title = "My subbed show"
        show.save

        assert show.subbed

        (1..10).each do |e|
            episode = Episode.new
            episode.show_id = show.id
            assert episode.has_subs?
        end
    end

    test "Dubbed shows should not have subs" do
        show = Show.new
        show.dubbed = true
        show.title = "My dubbed show"
        show.save

        assert show.dubbed

        (1..10).each do |e|
            episode = Episode.new
            episode.show_id = show.id
            assert_not episode.has_subs?
        end
    end
end
