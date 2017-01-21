class Utils

    require 'fileutils'

    def self.get_parent_directory(filename,check=false)
        if filename.instance_of? String
            parts = filename.split("/")
            parts.pop
            parts.join("/")
        else
            p "no filename or no / in the filename: #{filename}"
            nil
        end
    end

    def self.create_file(filename, contents)
        dir = Utils.get_parent_directory filename
        FileUtils.mkdir_p(dir) if !dir.nil? and !dir.empty?
        begin
            File.open(filename, "wb") do |file| file.print contents end if contents
        rescue
            false
        else
            true
        end
    end

    def self.delete_files(filenames)
        count = 0
        if filenames
            filenames.each do |f|
                if f
                    begin
                        self.delete_file f
                        count += 1
                    rescue Errno::ENOENT => e
                        # Could not delete file
                        next
                    end
                end
            end
        end
        count
    end

    def self.delete_file(filename)
        FileUtils.rm filename
    end
    
    def self.check_valid_email(email_address)
        return nil if email_address.nil?
        regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
        result = email_address =~ regex
        !result.nil?
    end

    def Utils.random(length=10)
        (0...length).map{ (65+rand(26)).chr }.join
    end

    def Utils.hex_random(length=10)
        (0...length).map{ (65+rand(6)).chr }.join
    end

    def Utils.colour_random
        '#' + hex_random(6)
    end

    def Utils.color_random
        Utils.colour_random
    end

    def self.choose_between(one, two)
        one + rand(two)
    end

    def Utils.today(hour_of_day=true)
        today = Time.now
        hour = Utils.pretty_number today.hour
        min = Utils.pretty_number today.min
        sec = Utils.pretty_number today.sec
        ok = hour_of_day ? " | #{hour}:#{min}:#{sec}" : ""
        "#{Utils.full_date_from today.year, today.month, today.day}#{ok}"
    end

    def self.search(string, list, instance_attributes=[:get_title], limit: 10, sort_by: nil)
        return list if string.to_s.strip.empty?
        return list if instance_attributes.nil? or instance_attributes.empty?
        res = []
        string.downcase!
        count = 0
        list = list.all.sort_by {|item| item.method(sort_by).call} unless sort_by.nil?
        list.each do |item|
            break if limit != nil && count == limit
            instance_attributes.each do |attrb|
                break if limit != nil && count == limit
                found = item.method(attrb).call
                attribute = found.to_s.strip.downcase
                # Check if the string is the same as the attribute
                if attribute == string
                    add_to_list(res, found)
                    count += 1
                    next
                end

                # Check if the string is contained in the attribute
                if attribute.include? string
                    add_to_list(res, found)
                    count += 1
                    next
                end

                # Check if some letters were found (ie: entered: "uot", found: "u Ottawa")
                attribute.delete!(" ", "    ")
                if attribute == string or attribute.include? string
                    add_to_list(res, found)
                    count += 1
                    next
                end
            end
        end
        res
    end

    def self.add_to_list(list, what, doubles: false)
        list.push(what) if doubles or !list.include? what
    end

    def Utils.pretty_number(number)
        if not number
            ""
        elsif number == 0
            "00"
        else
            if number > 0
                number <= 9 ? "0#{number}" : number.to_s
            else
                number = -number
                "-#{Utils.pretty_number number}"
            end
        end
    end

    def Utils.get_ordinal_number(number, pretty_number: true)
        number = number.to_i
        return number.ordinalize if not pretty_number
        return "" if not number
        return 0.ordinalize if number == 0
        return number <= 9 ? "0#{number.ordinalize}" : number.ordinalize if number > 0
        return "-0#{(-number).ordinalize}" if number >= -9
        number.ordinalize
    end

    def Utils.date_from(model=nil, created_at=true)
        if model != nil
            if created_at
                date = model.created_at.getlocal
            else
                date = model.updated_at.getlocal
            end
            text_day = get_day_from date
            num_m_date = date.mday
            month = get_month date.month
            year = date.year
            "#{text_day}, #{month} #{num_m_date} #{year}"
        else
            "N/A"
        end
    end

    def Utils.get_date_from_time(time)
        time = Time.now if not time
        Utils.full_date_from time.year, time.month, time.day, time.hour, time.min, time.sec
    end

    def Utils.full_model_date_from(model=nil, created_at=true)
        if model != nil
            if created_at
                date = model.created_at.getlocal
            else
                date = model.updated_at.getlocal
            end
            text_day = get_day_from date
            num_m_date = date.mday
            month = get_month date.month
            year = date.year

            hour = date.hour
            if date.min < 10
                minutes = "0#{date.min}"
            else
                minutes = date.min.to_s
            end
            "#{text_day}, #{month} #{num_m_date} #{year} at #{hour}:#{minutes}"
        else
            "N/A"
        end
    end

    def self.short_model_date_from(model=nil, created_at=true)
        if model != nil
            if created_at
                date = model.created_at.getlocal
            else
                date = model.updated_at.getlocal
            end
            if created_at
                res = "Today" if model.created_at.today?
            else
                res = "Today" if model.updated_at.today?
            end
            if res.nil?
                month = date.month
                day = date.day
                month = "0#{month}" if date.month < 10
                day = "0#{day}" if date.day < 10
                res = "#{date.year}/#{month}/#{day}"
            end
            return res
        else
            "N/A"
        end
    end

    def self.model_time_from(model=nil, created_at=true)
        if model != nil
            if created_at
                date = model.created_at.getlocal
            else
                date = model.updated_at.getlocal
            end
            hour = date.hour
            minutes = date.min
            seconds = date.sec
            hour = "0#{hour}" if date.hour < 10
            minutes = "0#{minutes}" if date.min < 10
            seconds = "0#{seconds}" if date.sec < 10
            "#{hour}:#{minutes}:#{seconds}"
        else
            "N/A"
        end
    end

    def self.normal_model_date_from(model=nil, created_at=true, sep: ":")
        date = self.short_model_date_from model, created_at
        return "N/A" if date == "N/A"
        time = self.model_time_from model, created_at
        return "N/A" if time == "N/A"
        "#{date} #{sep} #{time}"
    end

    def Utils.full_date_from(year, month, day, hour=0, minutes=0, seconds=0)
        if Utils.is_valid_date year, month, day
            "#{Utils.get_month(month.to_i)} #{Utils.get_ordinal_number day}, #{year} -"\
                " #{Utils.pretty_number hour}:#{Utils.pretty_number minutes}:#{Utils.pretty_number seconds}"
        else
            "N/A"
        end
    end

    def Utils.is_valid_date(year, month, day)
        year = year.to_i
        month = month.to_i
        day = day.to_i
        not (year == nil or year < 2000 or month == nil or month < 1 or month > 12 \
            or day == nil or day < 0 or day > 31) \
            and Utils.is_valid_date_of_month(Utils.is_leap_year(year), month, day)
    end

    def Utils.get_todays_date
        today = Date.today
        year = today.year
        month = today.month
        day = today.day
        [year, month, day]
    end

    def Utils.get_years_range
        min = Time.now.year
        max = min + 40 # years from today
        range = []
        (min..max).each do |year|
            range.push [year.to_s, year]
        end
        range
    end

    def Utils.get_months_range
        range = []
        (0..12).each do |month|
            range.push [Utils.get_month(month), month]
        end
        range
    end

    def Utils.get_days_range(all=true)
        range = []
        min = Time.now.day
        max = !all ? Utils.get_max_days_from_month(Time.now.month) : 31
        (min..max).each do |year|
            range.push [year.to_s, year]
        end
        range
    end

    def Utils.get_hours_range
        range = []
        (0..24).each do |hour|
            range.push [Utils.pretty_number(hour)+" h", hour]
        end
        range
    end

    def Utils.get_minutes_and_seconds_range(seconds=false)
        range = []
        (0..59).each do |m_s|
            range.push [Utils.pretty_number(m_s)+(seconds ? " s" : " min"), m_s]
        end
        range
    end

    def Utils.show_currency(money)
        return "N/A" if !money
        m = money.to_s
        return " - " if m.empty?
        "#{'%.02f' % money}$"
    end

    def Utils.get_class_from_string(string)
        if not string
            nil
        else
            string.split("::").inject(Object) do |mod, class_name|
                mod.const_get class_name
            end
        end
    end

    def self.get_todays_day_index
        get_day_index_from DateTime.now
    end

    private
        def Utils.get_month(month_id)
            case month_id
            when 1
                "January"
            when 2
                "February"
            when 3
                "March"
            when 4
                "April"
            when 5
                "May"
            when 6
                "June"
            when 7
                "July"
            when 8
                "August"
            when 9
                "September"
            when 10
                "October"
            when 11
                "November"
            when 12
                "December"
            else
                "#{month_id}"
            end 
        end

        def Utils.get_day_from(date)
            if date != nil
                if date.monday?
                    "Monday"
                elsif date.tuesday?
                    "Tuesday"
                elsif date.wednesday?
                    "Wednesday"
                elsif date.thursday?
                    "Thursday"
                elsif date.friday?
                    "Friday"
                elsif date.saturday?
                    "Saturday"
                else
                    "Sunday"
                end 
            else
                ""
            end
        end

        def Utils.get_day_index_from(date)
            if date != nil
                if date.monday?
                    1
                elsif date.tuesday?
                    2
                elsif date.wednesday?
                    3
                elsif date.thursday?
                    4
                elsif date.friday?
                    5
                elsif date.saturday?
                    6
                else
                    7
                end 
            else
                ""
            end
        end

        def Utils.is_leap_year(year)
            if year % 4 != 0
                false
            elsif year % 100 != 0
                true
            elsif year % 400 != 0
                false
            else
                true    
            end
        end

        def Utils.is_valid_date_of_month(leap_year, month, date)
            if date < 0
                false
            end
            if leap_year and month == 2
                date < 30
            elsif month == 2
                date < 29
            else
                if month == 1 or month == 3 or month == 5 or month == 7 or month == 8 \
                    or month == 10 or month == 11
                    date < 32
                else
                    date < 31
                end
            end
        end

        def Utils.get_max_days_from_month(month)
            case month
            when 1,3,5,7,8,10
                31
            when 2 
                Utils.is_leap_year(Time.now.year) ? 29 : 28
            else
                30
            end
        end

end
