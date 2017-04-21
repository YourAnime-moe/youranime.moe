# Welcome to Tanoshimu!
### 楽しむ (lit. To have fun)

#### What is it?
This is the repository of a functionnal streaming application. Check out a
live demo [here](https://akinyele.herokuapp.com/#Tanoshimu) on my website!

#### How can I use it?
You can visit [https://tanoshimu.herokuapp.com](https://tanoshimu.herokuapp.com)
to get started (may take a couple of seconds to load up). But you will need a
username and password to get in. [mailto:akinyele.akintola.febrissy@gmail](Send me an email)
to get your own log in!

#### How do I contribute?
I will initialize a sqlite3 file for the database. Simply running a migration will
not work, but I will still post information on how to get started with the app.

This is a rails application, so you will have to have Ruby and Ruby on Rails installed.
Once you've installed your development environment, simply run:
```
git clone git@github.com:/thedrummeraki/tanoshimu.git
cd tanoshimu
bundle
rails s
```

#### How do I view the models?
As the time of write this README, the following models available are:
```
User 		# User model used to identify the current user
News 		
Show 		# Contains information about shows available to watch that has several Episodes.
Episode		# Instance of an episode that has exactly one Show.

```
Go to the CLI (command line interface) by running...:
```
rails c
```
... and type:
```
users = User.all 		# Gets all saved User instances
episodes = Episode.all  # Gets all saved Episode instances
shows = Show.all 		# Gets all saved Show instances
....
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

