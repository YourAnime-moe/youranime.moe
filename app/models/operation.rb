# frozen_string_literal: true

class Operation < FrozenRecord::Base
  GITHUB_REPO_TREE_HEROKU_PATH = 'https://github.com/YourAnime-moe/youranime.moe/tree/heroku'

  def constant_name
    parent = parent_constant_name.name
    name = klass['name']

    combined_name = [parent, name].join('::')
    combined_name.constantize
  end

  def constant_location
    # resolve the constant
    constant_name

    # then find out where it is
    parent_constant_name.const_source_location(klass['name'])
  end

  def github_link
    path, line = constant_location
    github_path = path.sub(File.expand_path('.'), GITHUB_REPO_TREE_HEROKU_PATH)
    [github_path, "#L#{line}"].join
  end

  def parent_constant_name
    (klass['parent'] || 'Object').constantize
  end
end
