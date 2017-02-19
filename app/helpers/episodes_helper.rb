module EpisodesHelper

    def videojs_config
        Config.all["videojs"]
    end

    def videojs_version
        videojs_config["version"]
    end

end
