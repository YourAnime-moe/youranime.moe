class JSONConfig

    def self.get(path, contents=nil, log: false)
        contents = [] if contents.nil?
        begin
            to_parse = open path, "r" do |io| io.read end
        rescue Errno::ENOENT => e
            throw Exception.new "File \"#{path}\" does not exist"
        end
        p "To parse: #{to_parse}" if log
        parsed = JSON.parse to_parse
        if parsed
            parsed.each do |c|
                contents.push c
            end
        end
    end

end
