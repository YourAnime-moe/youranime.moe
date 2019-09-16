# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# These are not production values ;)
User.create(
  [
    {
      username: 'tanoshimu',
      password: 'tanoshimu',
      password_confirmation: 'tanoshimu',
      admin: false,
      is_activated: true,
      name: 'Regular User',
      google_user: false,
      demo: true,
      limited: false
    },
    {
      username: 'admin',
      password: 'admin',
      password_confirmation: 'admin',
      admin: true,
      is_activated: true,
      name: 'Admin User',
      google_user: false,
      demo: false,
      limited: false
    },
    {
      username: 'google',
      password: 'google',
      password_confirmation: 'google',
      admin: false,
      is_activated: true,
      name: 'Google User',
      google_user: true,
      demo: false,
      limited: true
    }
  ]
)

Show.create(
  show_type: 0,
  dubbed: false,
  subbed: true,
  starring: 'Kakihara Tetsuya, Hirano Aya, Kugimiya Rie',
  movie: false,
  average_run_time: 23,
  show_number: 1,
  year: 2012,
  alternate_title: 'Fairy Tail',
  published: true,
  en_description: 'The world of Earth-land is home to numerous guilds where wizards apply their magic for paid job requests',
  tags: %w[magic fantasy comedy],
  fr_title: 'Fairy Tail',
  roman_title: 'Fearii Teiru',
  fr_description: 'Dans le royaume de Fiore, il existe parmi le commun des mortels des hommes et des femmes qui manipulent la magie : ils sont appelés mages.',
  en_title: nil,
  banner_url: nil
)
