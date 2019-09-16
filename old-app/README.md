# Welcome to YourAnime (formerly Tanoshimu)! 
<a href="https://travis-ci.org/thedrummeraki/tanoshimu"><img src="https://travis-ci.org/thedrummeraki/tanoshimu.svg?branch=heroku"/></a>
<a href="https://codeclimate.com/github/thedrummeraki/tanoshimu/maintainability"><img src="https://api.codeclimate.com/v1/badges/abb303c2f3865a743c34/maintainability" /></a>
[![Coverage Status](https://coveralls.io/repos/github/thedrummeraki/tanoshimu/badge.svg?branch=heroku)](https://coveralls.io/github/thedrummeraki/tanoshimu?branch=heroku)
### 楽しむ (lit. To have fun)
<a href="https://tanoshimu.herokuapp.com"><img src="https://youranime.moe/img/tanoshimu.png" width="100" height="100"/></a>

#### How can I use it?
You can visit [youranime.moe](http://youranime.moe)
to get started (may take a couple of seconds to load up). But you will need a
username and password to get in. **You can register with a Google account, but
your account will have limited access** as these accounts are consided demo account.
[Send me an email](mailto:akinyele.kafe.febrissy@gmail.com)
to get an account with full access! **Please note that the contents (ie: videos) of this application 
are not available publicly for copyright reasons. This application is by all means not built 
for commercial use.**

##### Side note
Also, the version online is running the latest code on the branch `heroku`. So this
means, whatever is on `heroku` is being used in production! The `master` is just more
of a formality. Also, I don't want to make `heroku` my main branch to avoid desasters.

#### Technologies
The following technologies made this app into what it is today:
- [Ruby on Rails 6](http://rubyonrails.org/) (Server-side and API development)
- [Bulma.io](https://bulma.io/) (CSS library)
- [jQuery](https://jquery.com/) (Various JavaScript libraries, mostly used for AJAX here)
- Ruby (Other than Ruby of Rails, lots of cool Ruby libraries are used - See [Gemfile](Gemfile))
- _and more to come!_

#### How do I contribute or check out the project?
This is a Rails application, however you will need to have [Docker](https://www.docker.com) 
and [Docker compose](https://docs.docker.com/compose/) installed on your computer.
```
git clone git@github.com:/thedrummeraki/tanoshimu.git
cd tanoshimu
docker-compose build
docker-compose run web bundle exec rails db:setup
docker-compose up
```
Once the server is running, you can go to http://localhost:3000. You can login with credentials ```tanoshimu```
(both username and password).

#### Is this project alive? 
YES YES YES! When was the last commit? ;)

### About Tanoshimu
This project was originally called *My Akinyele* and was running Rails 4. The UI and the code design 
were terrible so I decided to change everything in January 2017 for the best. A big change was the use of
Slim and the heavy use of Bootstrap (as well as better overall code architecture).

In July 2017, I went from Bootstrap to Materialize CSS. The transition was nothing short of amazing. It's
impresive how fuild the CSS transition and translation was.

Starting October 2017, I started re-visiting a feature I discovered with my [reviews website](https://reviews.herokuapp.com):
internal messaging between users. Most apps these days have a messaging feature. I wanted this feature to become a 
requirement very soon become out of scope 

In June 2019, after a long pause of development from May 2018 to April 2019 (hey I have school you know!), I worked
hard refactoring the code (making it better) and decided it was time for this site to become public. The app was
now renamed to [YourAnime.moe](http://youranime.moe). A new look was implemented in February 2019, then once more
in April 2019.

**Please note that the contents (ie: videos) of this application are not available publicly for copyright reasons. 
This application is by all means not built for commercial use.**
