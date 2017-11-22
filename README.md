# Welcome to Tanoshimu! 
<a href="https://circleci.com/gh/thedrummeraki/tanoshimu"><img src="https://circleci.com/gh/thedrummeraki/tanoshimu/tree/master.svg?style=shield"/></a>
### 楽しむ (lit. To have fun)
<a href="https://tanoshimu.herokuapp.com"><img src="public/favicon.ico" width="100" height="100"/></a>

#### What is it?
This is the repository of a streaming application. Check out a live demo 
[here](https://akinyele.herokuapp.com/#tanoshimu) on my website!

#### How can I use it?
You can visit [https://tanoshimu.herokuapp.com](https://tanoshimu.herokuapp.com)
to get started (may take a couple of seconds to load up). But you will need a
username and password to get in. [Send me an email](mailto:akinyele.akintola.febrissy@gmail.com)
to get your own login credentials! **Please note that the contents (ie: videos) of this application 
are not available publicly for copyright reasons. This application is by all means not built 
for commercial use.**

##### Side note
Also, the version online is running the latest code on the branch `heroku`. So this
means, whatever is on `heroku` is being used in production! The `master` is just more
of a formality. Also, I don't want to make `heroku` my main branch to avoid desasters.

#### Technologies
The following technologies made this app into what it is today:
- [Ruby on Rails 5](http://rubyonrails.org/) (Server-side and API development)
- [Materialize CSS](http://materializecss.com/) (JavaScript and CSS library, similar to Bootstrap)
- [jQuery](https://jquery.com/) (Various JavaScript libraries, mostly used for AJAX here)
- [Slim](http://slim-lang.com/) (Jade-based Ruby HTML generator, make the HTML easier to read when developing)
- Python (Used for generating video thumbnails. Still needs a lot of work)
- Ruby (Other than Ruby of Rails, lots of cool Ruby libraries are used - See [Gemfile](Gemfile))
- _and more to come!_

#### RESTful API
The application comes with a JSON API. It is not fully functionally yet, but allows
you to login, get information about the current user, get a list of available shows
and episodes. Here are a couple of useful endpoints:
```
POST /api/token => {token:string, message:string}
	username: Your username in base64
	password: Your password in base64

GET *or* POST /api/check => {message:string, success:boolean}
    token: Your token

GET *or* POST /api/get/shows => {shows:[list]}
	token: Your token

GET *or* POST /api/get/episodes => {episodes:[list]}
	token: Your token

GET *or* POST /api/get/episode/path => {path:null or string, message:string, success:boolean}
	token: Your token

GET *or* POST /api/get/news => {news:[list]}
	token: Your token

GET *or* POST /api/get/user => {all user information}
	token: Your token

POST /api/token/destroy => {message:string}
	token: Your token
```
You can use this API on the production app (provided you have login credentials), or on
the development application. How? Go to the next section explaining how to install it and
to get it running!

More endpoints coming soon!

#### How do I contribute or check out the project?
This is a Rails application, so you will have to have *Ruby* and *Ruby on Rails* installed.
Once you have your development environment set up, simply run:
```
git clone git@github.com:/thedrummeraki/tanoshimu.git
cd tanoshimu
cp database.sample db/development.sqlite3
bundle						# Installs all necessary rails packages
bundle exec rake db:migrate         # Initialize the database if necessary
rails s						# Run the server
```
Once the server is running, you can go to http://localhost:3000. You can login with credentials ```tanoshimu```
(both username and password).

#### How do I view the models?
As the time of write this README, the following models available are:
```
User 						# User model used to identify the current user
News 		
Show 						# Contains information about shows available to watch that has several Episodes.
Episode						# Instance of an episode that has exactly one Show.

```
Go to the CLI (command line interface) by running...:
```
rails c
```
... and type:
```ruby
users = User.all 			# Gets all saved User instances
episodes = Episode.all  	# Gets all saved Episode instances
shows = Show.all 			# Gets all saved Show instances
...etc...
```

Have a look at [ActiveModels](http://guides.rubyonrails.org/active_model_basics.html) to
know more about simple methods you can use. Also, take a look at [schema.rb](db/schema.rb) to
see which model-specific methods are available.

#### But where are all the files?
| Controllers      | Models     | Views     |
| ---------------- |:----------:| ---------:|
| app/controllers  | app/models | app/views |


#### Is this project alive? 
Yes! Last big update was in September 2017 and I made the development easier in November 2017. I started 
this project in December 2016, and plan to continue for a couple of years.

### About Tanoshimu
This project was originally called *My Akinyele* and was running Rails 4. The UI and the code design 
were terrible so I decided to change everything in January 2017 for the best. A big change was the use of
Slim and the heavy use of Bootstrap (as well as better overall code architecture).

In July 2017, I went from Bootstrap to Materialize CSS. The transition was nothing short of amazing. It's
impresive how fuild the CSS transition and translation was.

Starting October 2017, I started re-visiting a feature I discovered with my [reviews website](https://reviews.herokuapp.com):
internal messaging between users. Most apps these days have a messaging feature. I think this feature will become a 
requirement very soon. I want to add this feature because I want users to be able to share and recommend shows to
each other.

**Please note that the contents (ie: videos) of this application are not available publicly for copyright reasons. 
This application is by all means not built for commercial use.**
