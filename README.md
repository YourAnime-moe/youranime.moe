# Welcome to YourAnime.mow (formerly Tanoshimu)!

<img src="https://badge.buildkite.com/98ef2a29fa705886db86496540edd3be0b331fcdc7cedbecad.svg?branch=heroku" alt="Buildkite CI">
<a href="https://codeclimate.com/github/thedrummeraki/tanoshimu/maintainability"><img src="https://api.codeclimate.com/v1/badges/abb303c2f3865a743c34/maintainability" /></a>

### What is this?

#### The next go-to anime streaming information website.

Find out when your favourite anime airs and where you can watch it. In the near future, you will be able to organize your watch list per streaming platform (integration with anime-management sites like Anilist or MAL may be implemented).

#### How can I use it?

You can visit [youranime.moe](https://youranime.moe) to get started.

#### Technologies

The following technologies made this app into what it is today:

- [Ruby on Rails 6.1](http://rubyonrails.org/) (Server-side and API development)
- [React](https://reactjs.org) (A JavaScript library for building user interfaces)
- [Material-UI](https://material-ui.com/) (React components for faster and easier web development)
- [GraphQL](https://graphql.org) (A graph-based query language, alternative to REST)
- [Docker](https://www.docker.com) (For running in app in a containerized environment)
- [Heroku](https://heroku.com) (Used mostly for background jobs and proxy security)
- [DigitalOcean](https://www.digitalocean.com) (Alternative to AWS)
- [Vercel](https://vercel.com) (Hosting the front-end application)

#### How do I contribute or check out the project?

I do not accept public contributions at the moment. Please contact me by email if you wish to run the project locally. Please note that this is not my full time job so I may take a little before answering. 😅

#### Is this project alive?

Yes.

### About Tanoshimu

This project was originally called _My Akinyele_ and was running Rails 4. The UI and the code design
were terrible so I decided to change everything in January 2017 for the best. A big change was the use of
Slim and the heavy use of Bootstrap (as well as better overall code architecture).

In July 2017, I went from Bootstrap to Materialize CSS. The transition was nothing short of amazing. It's
impresive how fuild the CSS transition and translation was.

Starting October 2017, I started re-visiting a feature I discovered with my [reviews website](https://reviews.herokuapp.com):
internal messaging between users. Most apps these days have a messaging feature. I wanted this feature to become a
requirement very soon become out of scope

In June 2019, after a long pause of development from May 2018 to April 2019 (hey I have school you know!), I worked
hard refactoring the code (making it better) and decided it was time for this site to become public. The app was
now renamed to [YourAnime.moe](https://youranime.moe). A new look was implemented in February 2019, then once more
in April 2019.

In early 2021, the site's new goal was now about to promoting which anime can be watched legally in your country. I've decided to convert the Rails app into a GraphQL API that is used by a rich client, written in React. The interface has changed a lot since then and the focus is now to put then enphasis on **where** certain anime can be watched.
