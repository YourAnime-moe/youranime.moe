# YourAnime.moe utilities

Welcome to `tanoshimu_utils`! This gem is what I like to call "just a couple of utilities shared accross the apps to make development much easier."

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tanoshimu_utils'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tanoshimu_utils

## Usage

### Concerns

| `include`                                  | Description | Example |
| ------------------------------------------ | ----------- | ------- |
| `TanoshimuUtils::Concerns::GetRecord`      | Add `.record` to return a model from the table `.used_by_model` with primary key `.model_id`. | `Model.first.record` |
| `TanoshimuUtils::Concerns::Identifiable`   | Fills up the `.identification` field with a unique token. | Use with classes like `Admin`, `User`, `Staff`, etc... (anyone that can log on to the app) |
| `TanoshimuUtils::Concerns::ResourceFetch`  | For an ActiveStorage attachment `res`, adds `res_url` (get the url), `res_url!` (fetch from AWS), `res?` (make sure it is existant and attached) | Use classes that have attachments (like images). If `user` has `avatar`, then `user.avatar?`, `user.avatar_url`, `user.avatar_url!` are valid calls. |
| `TanoshimuUtils::Concerns::RespondToTypes` | Adds `respond_to_types` class method to add `field?` for a field `field`. | `respond_to_types [:admin, :regular, :guest]` is a valid class for a `User` class. |
| `TanoshimuUtils::Concerns::Translatable`   | Depending on the current locale, adds a `translates` class method to create a field that returns the value | `translates :value, through: [:en, :fr], default: :fr` creates a method `.value` that returns the field `.fr` if the locale is French, `.en` if the locale is English. French is returned if another available locale is set. |

### Validators

| `include`                                   | Description | Example |
| ------------------------------------------- | ----------- | ------- |
| `TanoshimuUtils::Validators::PresenceOneOf` | Adds the class method `validate_presence_one_of` to check if at lease one of the fields are set. | `validate_presence_one_of [:field1, :field2, :field3]` will validate if `:field1` or `field2` or `field3` is set. If none are set, fails. |
| `TanoshimuUtils::Validators::UserLike`      | Adds the class method `validate_like_user` to check if the user-like class (`User`, `Admin`, `Staff`, etc.) has a `name`, a `username` and a `user_type` (the latter must be in the array `user_types`). | `validate_like_user user_types: [:admin, :regular]` only allows user-like models to be either admin or regular. |

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/tanoshimu_utils.
