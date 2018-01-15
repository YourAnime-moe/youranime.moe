class Config

    CONFIG_PATH = "config/config.json"
    LINK_TAG_SIZE = 2

    def self.main_host(path=nil)
        return _fetch_host(path, :main) if Rails.env == "production"
        return _fetch_host(path, :dev) if Rails.env == "development"
        return _fetch_host(path, :test) if Rails.env == "test"
    end

    def self.admin_host(path=nil, *tags)
        host = Rails.env == "production" ? _fetch_host(path, :admin) : _fetch_host(path, "admin-test")
        return host if tags.nil? or tags.empty?
        tags = tags.each_slice(LINK_TAG_SIZE).to_a
        tags.reject!{|t| t.empty?}
        tags.each do |tag_array|
            next if tag_array.size != LINK_TAG_SIZE
            key = tag_array[0]
            value = tag_array[1]
            if host.include? "?"
                host << "&"
            else
                host << "?"
            end
            host << "#{key}=#{value}"
        end
        host
    end

    def self.hosts(path=nil)
        self.all(path)["hosts"]
    end

    def self.api(path=nil)
        self.all(path)['api']
    end

    def self.env(key=nil, default=nil, path=nil)
        h = self.api(path)["env"]
        return h if key.nil? && default.nil?
        value = h[key]
        value ? value : default
    end

    def self.all(path=nil)
        path = CONFIG_PATH if path.nil?
        JSONConfig.get(path)
    end

    def self.path(path)
        main = self.main_host
        if !main.end_with? "/" and !path.start_with? "/"
            main << "/"
        end
        main << path
    end

    private
        def self._fetch_host(path, key)
            key = key.to_s
            return nil if key.empty?
            hosts_info = self.hosts(path)[key]
            return nil if hosts_info.nil?
            protocol = hosts_info["protocol"]
            protocol = "http" if protocol.nil?
            sub_domain = hosts_info["sub_domain"]
            domain = hosts_info["domain"]
            if hosts_info["env"]
                domain = ENV[domain]
            end
            raise Exception.new("Domain was not found for key #{key}.") if domain.nil?
            path = protocol + "://"
            path << sub_domain + "." unless sub_domain.nil?
            path << domain
        end


end
