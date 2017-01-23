class Config

    CONFIG_PATH = "config/config.json"
    LINK_TAG_SIZE = 2

    def self.main_host
        _fetch_host(:main)
    end

    def self.admin_host(*tags)
        host = Rails.env == "production" ? _fetch_host(:admin) : _fetch_host("admin-test")
        return host if tags.nil? or tags.empty?
        tags = tags.each_slice(LINK_TAG_SIZE).to_a
        tags.reject!{|t| t.empty?}
        p tags
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

    def self.hosts
        self.all["hosts"]
    end

    def self.all
        JSONConfig.get(CONFIG_PATH)
    end

    def self.path(path)
        main = self.main_host
        if !main.end_with? "/" and !path.start_with? "/"
            main << "/"
        end
        main << path
    end

    private
        def self._fetch_host(key)
            key = key.to_s
            return nil if key.empty?
            hosts_info = self.hosts[key]
            return nil if hosts_info.nil?
            protocol = hosts_info["protocol"]
            protocol = "http" if protocol.nil?
            sub_domain = hosts_info["sub_domain"]
            domain = hosts_info["domain"]
            raise AppError.new if domain.nil?
            path = protocol + "://"
            path << sub_domain + "." unless sub_domain.nil?
            path << domain
        end


end
