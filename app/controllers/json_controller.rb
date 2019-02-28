class JsonController < ApplicationController

  def search
    instance = params[:instance]
    keyword = params[:keyword]
    limit = params[:limit]
    sort_by = params[:sort_by]

    klass = get_class_from_instance_tag(instance)
    if klass.nil?
      render json: {message: "Invalid instance.", response: "Class was no found.", success: false}
      return
    end

    begin
      list = klass.all
    rescue NameError => e
      render json: {message: "Invalid instance.", response: e.message, success: false}
      return
    end

    begin
      res = Utils.search(keyword, list, get_instances_from_class(klass), limit: limit, sort_by: sort_by)
      if params[:whole_thing] == "true"
        ress = []
        res.each do |title|
          next if title.class != String
          Show.all.each do |show|
            if show.get_title.downcase == title.downcase
              ress.push show
              break
            end
            if show.title.downcase == title.downcase
              ress.push show
            end
          end
        end
        res = ress
      end
    rescue NameError => e
      render json: {message: "Invalid data entered", response: e.message, success: false}
      return
    end

    render json: {message: "Success", success: true, response: res, get_host: params[:get_host] == "true" ? Config.main_host : nil}
  end

  def find_show
    if params[:given_title]
      Show.all.each do |show|
        if show.get_title.downcase == params[:given_title].downcase
          @show = show
          break
        end
        if show.title.downcase == params[:given_title].downcase
          @show = show
        end
      end
    end
    if @show
      json = {id: @show.id}
    else
      json = {err: "Show was not found. We'll fix this as soon as possible"}
    end
    render json: json
  end

  def episode_get_comments
    id = params[:id]
    if id.nil?
      render json: {err: 'Episode id was not specified.'}
    elsif Show::Episode.find_by(id: id).nil?
      render json: {err: 'Episode was not found.'}
    else
      episode = Show::Episode.find(id)
      if params[:usernames]
        usernames = params[:usernames].strip.downcase == 'true'
      else
        usernames = false
      end
      comments = episode.get_comments(usernames: usernames)
      render json: {instance: episode, comments: comments.reverse}
    end
  end

  def episode_add_comment
    id = params[:id]
    if id.nil?
      render json: {err: 'Episode id was not specified.'}
    elsif Show::Episode.find_by(id: id).nil?
      render json: {err: 'Episode was not found.'}
    else
      e = Show::Episode.find(id)
      if params[:comments].to_s.strip.size == 0
        render json: {err: 'No text was received.'}
      else
        comment = {text: params[:comments], user_id: current_user.id, time: Time.now}
        result = e.add_comment(comment)
        comments = e.comments || []
        render json: {message: result[:message], success: result[:success], comments: comments, instance: e}
      end
    end
  end

  def set_watched
    @episode = Show::Episode.find(params[:id])
    render json: {message: "sucess", success: current_user.add_episode(@episode)}
  end

  def get_next_episode_id
    if params[:check_setting] == "true"
      unless current_user.can_autoplay?
        render json: {success: false, message: 'The user does not want to autoplay.'}
        return
      end
    end
    episode = Show::Episode.find_by(id: params[:id])
    if episode.nil?
      render json: {success: false}
    else
      next_episode = episode.next
      next_id = next_episode.nil? ? nil : next_episode.id
      render json: {success: true, next_id: next_id}
    end
  end

  def all_users
    result = {data: {}}
    User.all.each do |user|
      next if user.get_name.nil? || user.username.nil?
      if user.id == current_user.id
        result[:data]["Me | " + user.get_name + " | " + user.username] = nil
      else
        result[:data][user.get_name + " | " + user.username] = nil
      end
    end
    render json: result
  end

  private
  def get_class_from_instance_tag(tag)
    tag = tag.to_s
    return nil if tag.strip.empty?
    return Show if tag == "show" or tag == "shows"
    return Episode if tag == "episode" or tag == "episodes"
  end

  def get_instances_from_class(klass)
    klass.instances
  end
end
