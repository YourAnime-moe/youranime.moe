require 'i18n'

class Utils

  def self.tags
    {
      action: I18n.t('tags.tags.action'),
      adventure: I18n.t('tags.tags.adventure'),
      budou: I18n.t('tags.tags.budou'),
      comedy: I18n.t('tags.tags.comedy'),
      demons: I18n.t('tags.tags.demons'),
      drama: I18n.t('tags.tags.drama'),
      ecchi: I18n.t('tags.tags.ecchi'),
      fantasy: I18n.t('tags.tags.fantasy'),
      game: I18n.t('tags.tags.game'),
      harem: I18n.t('tags.tags.harem'),
      historical: I18n.t('tags.tags.historical'),
      horror: I18n.t('tags.tags.horror'),
      josei: I18n.t('tags.tags.josei'),
      magic: I18n.t('tags.tags.magic'),
      movie: I18n.t('tags.tags.movie'),
      mecha: I18n.t('tags.tags.mecha'),
      music: I18n.t('tags.tags.music'),
      mystery: I18n.t('tags.tags.mystery'),
      non_school: I18n.t('tags.tags.non_school'),
      parody: I18n.t('tags.tags.parody'),
      psychological: I18n.t('tags.tags.psychological'),
      romance: I18n.t('tags.tags.romance'),
      seinen: I18n.t('tags.tags.seinen'),
      slice: I18n.t('tags.tags.slice'),
      sci_fi: I18n.t('tags.tags.sci_fi'),
      sports: I18n.t('tags.tags.sports'),
      super: I18n.t('tags.tags.super'),
      supernatural: I18n.t('tags.tags.supernatural'),
      thriller: I18n.t('tags.tags.thriller'),
      vampire: I18n.t('tags.tags.vampire'),
      yaoi: I18n.t('tags.tags.yaoi'),
      yuri: I18n.t('tags.tags.yuri')
    }
  end

  def self.valid_tags
    valid_sym = self.tags.keys
    valid_string = valid_sym.map { |tag| tag.to_s }
    valid_sym + valid_string
  end

  def self.get_tag_name(key)
    self.tags[key]
  end

  require 'fileutils'

  def self.get_filename(filepath)
    return nil if filepath.blank?
    parts = filepath.split('/')
    parts[parts.length-1]
  end

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
    FileUtils.mkdir_p(dir) if !dir.nil? && !dir.empty?
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

    def self.random(length=10)
      (0...length).map{ (65+rand(26)).chr }.join
    end

    def self.hex_random(length=10)
      (0...length).map{ (65+rand(6)).chr }.join
    end

    def self.colour_random
      '#' + hex_random(6)
    end

    def self.color_random
      Utils.colour_random
    end

    def self.choose_between(one, two)
      one + rand(two)
    end

    def self.today(hour_of_day=true)
      today = Time.now
      hour = Utils.pretty_number today.hour
      min = Utils.pretty_number today.min
      sec = Utils.pretty_number today.sec
      ok = hour_of_day ? " | #{hour}:#{min}:#{sec}" : ""
      "#{Utils.full_date_from today.year, today.month, today.day}#{ok}"
    end

    def self.search(string, list, instance_attributes=[:title], limit: 10, sort_by: nil)
      return list if string.to_s.strip.empty?
      return list if instance_attributes.nil? || instance_attributes.empty?
      res = []
      string.downcase!
      count = 0
      list = list.all.sort_by {|item| item.method(sort_by).call} unless sort_by.nil?
      list.each do |item|
        if item.instance_of? Show or item.instance_of? Episode
          next unless item.is_published?
        end
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

    #    def self.split_array(klass, sort_by: 4, reverse: false)
    #        unless klass.instance_of?(Class) and (klass < ActiveRecord::Base)
    #            raise Exception.new("Please pass in instance of ActiveRecord::Base")
    #        end
    #        amount = klass.all.size
    #        return [] if amount == 0
    #        return [klass.first] if amount == 1
    #        revs = []
    #        gen_list = []
    #        sub_list = []
    #        pos = reverse ? klass.last.id : klass.first.id
    #        element = klass.find(pos)
    #        index = 0
    #        until false
    #            break if element.nil?
    #            pos = element.id
    #            current = pos % sort_by
    #            sub_list.push element if element.is_published?
    #            if sub_list.size == sort_by
    #                gen_list.push sub_list
    #                sub_list = []
    #            end
    #            should_stop = (reverse ? element.is_first? : element.is_last?)
    #            if should_stop
    #                gen_list.push sub_list
    #                break
    #            end
    #            element = reverse ? element.previous : element.next
    #            index += 1
    #        end
    #        gen_list.reject{|array| array.empty?}
    #    end

    def self.add_to_list(list, what, doubles: false)
      list.push(what) if doubles or !list.include? what
    end

    def self.pretty_number(number)
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

    def self.get_ordinal_number(number, pretty_number: true)
      number = number.to_i
      return number.ordinalize if not pretty_number
      return 0.ordinalize if number == 0
      return number <= 9 ? "0#{number.ordinalize}" : number.ordinalize if number > 0
      return "-0#{(-number).ordinalize}" if number >= -9
      number.ordinalize
    end

    def self.date_from(model=nil, created_at=true)
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

    def self.get_date_from_time(time)
      time = Time.now if not time
      Utils.full_date_from time.year, time.month, time.day, time.hour, time.min, time.sec
    end

    def self.full_model_date_from(model=nil, created_at=true)
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

    def self.full_date_from(year, month, day, hour=0, minutes=0, seconds=0, date_only=false)
      if Utils.is_valid_date year, month, day
        date = "#{Utils.get_month(month.to_i)} #{Utils.get_ordinal_number day}, #{year}"
        return date if date_only
        "#{date} - #{Utils.pretty_number hour}:#{Utils.pretty_number minutes}:#{Utils.pretty_number seconds}"
      else
        "N/A"
      end
    end

    def self.is_valid_date(year, month, day)
      year = year.to_i
      month = month.to_i
      day = day.to_i
      not (year == nil or year < 2000 or month == nil or month < 1 or month > 12 \
        or day == nil or day < 0 or day > 31) \
        and Utils.is_valid_date_of_month(Utils.is_leap_year(year), month, day)
      end

      def self.get_todays_date
        today = Date.today
        year = today.year
        month = today.month
        day = today.day
        [year, month, day]
      end

      def self.get_years_range
        min = Time.now.year
        max = min + 40 # years from today
        range = []
        (min..max).each do |year|
          range.push [year.to_s, year]
        end
        range
      end

      def self.get_months_range
        range = []
        (0..12).each do |month|
          range.push [Utils.get_month(month), month]
        end
        range
      end

      def self.get_days_range(all=true)
        range = []
        min = Time.now.day
        max = !all ? Utils.get_max_days_from_month(Time.now.month) : 31
        (min..max).each do |year|
          range.push [year.to_s, year]
        end
        range
      end

      def self.get_hours_range
        range = []
        (0..24).each do |hour|
          range.push [Utils.pretty_number(hour)+" h", hour]
        end
        range
      end

      def self.get_minutes_and_seconds_range(seconds=false)
        range = []
        (0..59).each do |m_s|
          range.push [Utils.pretty_number(m_s)+(seconds ? " s" : " min"), m_s]
        end
        range
      end

      def self.show_currency(money)
        return "N/A" if !money
        m = money.to_s
        return " - " if m.empty?
        "#{'%.02f' % money}$"
      end

      def self.get_class_from_string(string)
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

      def self.current_season(time=nil)
        d = time || Time.now
        if d.month >= 1 && d.month < 4
          # JAN -> MAR = Winter
          return 0
        elsif d.month >= 4 && d.month < 7
          # APR -> JUN = Spring
          return 1
        elsif d.month >= 7 && d.month < 10
          # JUL -> SEP = Summer
          return 2
        else
          # OCT -> DEC = Fall
          return 3
        end
      end

      def self.current_season_string(time=nil)
        time = time || Time.now
        season = self.current_season(time)
        season_string = nil
        season_string = I18n.t('time.seasons.winter') if season == 0
        season_string = I18n.t('time.seasons.spring') if season == 1
        season_string = I18n.t('time.seasons.summer') if season == 2
        season_string = I18n.t('time.seasons.fall') if season == 3
        "#{season_string} #{time.year}"
      end

      private
      def self.get_month(month_id)
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

      def self.get_day_from(date)
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

      def self.get_day_index_from(date)
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

      def self.is_leap_year(year)
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

      def self.is_valid_date_of_month(leap_year, month, date)
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

      def self.get_max_days_from_month(month)
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
