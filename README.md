
[![Docker Pulls](https://img.shields.io/docker/pulls/rtb4free/campaign-manager.svg)](https://hub.docker.com/r/rtb4free/campaign-manager/)
[![Docker Stars](https://img.shields.io/docker/stars/rtb4free/campaign-manager.svg)](https://hub.docker.com/r/rtb4free/campaign-manager/)
[![](https://images.microbadger.com/badges/version/rtb4free/campaign-manager.svg)](https://microbadger.com/images/rtb4free/campaign-manager "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/rtb4free/campaign-manager.svg)](https://microbadger.com/images/rtb4free/campaign-manager "Get your own image badge on microbadger.com")
[![Build Status](https://travis-ci.org/rtb4free/campaign-manager.svg?branch=master)](https://travis-ci.org/rtb4free/campaign-manager)

Campaign Manager - RTB4FREE Campaign Management UI
==================================================

Campaign management user interface for [RTB4Free](http://rtb4free.com/)

An image of this repo is available directly from [Docker Hub](https://hub.docker.com/r/rtb4free/campaign-manager/)


Getting Help
------------

User documentation can be found on [Read The Docs](https://rtb4free.readthedocs.io)


Source Code
-----------

To start working with code, first make sure you have the following installed on your computer:

* [Ruby v3.3.x](https://www.ruby-lang.org/en/downloads/releases/)
* [Rails v8.0.x](https://guides.rubyonrails.org/)
* [MySQL v8.0](https://www.mysql.com/)
* [Docker](https://www.docker.com/) (recommended for development)

Next, get the code from this Github repo:

```
git clone git@github.com:RTB4FREE/campaign-manager.git
cd campaign-manager
```

The RTB4Free campaign manager is a modern [Rails 8.x application](https://guides.rubyonrails.org/), and can be installed and managed in the standard Rails fashion:

Install using Rails:

```
bundle install
```

Configure the database:

```
rake db:setup
```

Run the tests:

```
rake test
```

Start the server:

```
rails s
```

Using Campaign Manager
----------------------

To run the campaign manager locally, open a browser to the host:

[http://localhost:3000](http://localhost:3000)

Username: `demo@rtb4free.com`
Password: `rtb4free`

For information about the campaign manager functionality:

[User Documentation](https://rtb4free.readthedocs.io)

Getting Support
---------------

There are various ways of getting support:

* Email us at [support@rtb4free.com](mailto://support@rtb4free.com)
* Add a Github issue:  [github.com/rtb4free/campaignmanager/issues](https://github.com/rtb4free/campaignmanager/issues)
* Join the [RTB4Free Slack Channel](https://join.slack.com/t/rtb4free/shared_invite/enQtNjYxNzc3NTQwMzIwLTlkNWYyMzY0NzA3MTNmMjc2M2I0NzkxYjE0NGIwYTljMjQ2YzAwYTBmMTJhNWM0ZDc0NTljNTA3NzFjNzZlNDI)
