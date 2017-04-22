# Welcome to Tanoshimu!
### 楽しむ (lit. To have fun)

#### What is it?
This is the repository of a streaming application. Check out a live demo 
[here](https://akinyele.herokuapp.com/#tanoshimu) on my website!

#### How can I use it?
You can visit [https://tanoshimu.herokuapp.com](https://tanoshimu.herokuapp.com)
to get started (may take a couple of seconds to load up). But you will need a
username and password to get in. [Send me an email](mailto:akinyele.akintola.febrissy@gmail)
to get your own login credentials!

#### API
The application comes with a JSON API. It is not fully functionally yet, but allows
you to login, get information about the current user, get a list of available shows
and episodes. Here are a couple of useful endpoints:
```
POST /api/token => {token, message}
	username: Your username in base64
	password: Your password in base64

GET /api/get/shows => {shows: [list of shows]}
	token :Your token

GET /api/get/episodes => {episodes: [list of episodes]}
	token :Your token

GET /api/get/news => {news: [list of news]}
	token :Your token

GET /api/get/user => {all user information}
	token :Your token

POST /api/token/destroy => {message}
	token: Your token
```
More coming soon!

#### How do I contribute?
I will create an sqlite3 file for the database. Simply running a migration will
not work, but I will still post information on how to get started with the app.

This is a Rails application, so you will have to have *Ruby* and *Ruby on Rails* installed.
Once you have your development environment set up, simply run:
```
git clone git@github.com:/thedrummeraki/tanoshimu.git
cd tanoshimu
bundle						# Installs all necessary rails packages
rails s						# Run the server
```

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
Yes! Last big update was in April 2017. I started this project in
December 2016, and plan to continue for a couple of years.

