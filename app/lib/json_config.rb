class JSONConfig

    def self.get(path, contents=nil)
        contents = [] if contents.nil?
        begin
            to_parse = open path, "r" do |io| io.read end
        rescue Errno::ENOENT => e
            puts e
        end
        parsed = JSON.parse to_parse
        if parsed
            parsed.each do |c|
                contents.push c
            end
        end 
    end

end
